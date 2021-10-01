Import-Module  .\es-helper.psm1
# Change ACCOUNT_ID, AWS_REGION and ES_DOMAIN_NAME
# AWS Region and Account ID
$ACCOUNT_ID = ""
$AWS_REGION = "eu-north-1"
$CLUSTER_NAME = "dev-test-4" # EKS CLUSTER NAME


# read template esdomain.json
$esdomain = Get-Content './templates/esdomain.json' -raw | ConvertFrom-Json
# name of elasticsearch cluster
$ES_DOMAIN_NAME = "k8slogging"
$esdomain.DomainName = $ES_DOMAIN_NAME 
# Elasticsearch version
$esdomain.ElasticsearchVersion = "7.4"
# Elasticsearch Instance Size
$esdomain.ElasticsearchClusterConfig.InstanceType = "r5.large.elasticsearch"
# Elasticsearch Instance Count
$esdomain.ElasticsearchClusterConfig.InstanceCount = 1
# Elasticsearch Disk Size (GB)
$esdomain.EBSOptions.VolumeSize = 100
# Elasticsearch Kibana User and Password
$esdomain.AdvancedSecurityOptions.MasterUserOptions.MasterUserName = "kibadmin"
$esdomain.AdvancedSecurityOptions.MasterUserOptions.MasterUserPassword = 'kibAdmin$es_2021'

$esdomain | ConvertTo-Json -depth 32| set-content './esdomain.json'
# replace real values in esdomain.json
(Get-Content './esdomain.json' -Raw).Replace("__ACCOUNT_ID__",$ACCOUNT_ID).Replace("__AWS_REGION__",$AWS_REGION).Replace("__ES_DOMAIN_NAME__",$ES_DOMAIN_NAME) | Set-Content ./esdomain.json 


# read template iam.json
$iam = Get-Content './templates/iam.json' -raw | ConvertFrom-Json
$iam.Statement[0].Resource = "arn:aws:es:${AWS_REGION}:${ACCOUNT_ID}:domain/${ES_DOMAIN_NAME}"
# replace real values in iam.json
$iam | ConvertTo-Json -depth 32| set-content './iam.json'

# create IAM Policy for fluentbit to access Elastic Search
aws iam create-policy   `
  --policy-name fluent-bit-policy `
  --policy-document file://./iam.json

# Enable OIDC provider
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --approve

# Change ACCOUNT_ID and CLUSTER_NAME
eksctl create iamserviceaccount `
    --name fluent-bit `
    --namespace logging `
    --cluster $CLUSTER_NAME `
    --attach-policy-arn "arn:aws:iam::${ACCOUNT_ID}:policy/fluent-bit-policy" `
    --approve `
    --override-existing-serviceaccounts

# Make sure  service account with the ARN of the IAM role is annotated
kubectl -n logging describe sa fluent-bit

# Create the Elastic Search cluster
aws es create-elasticsearch-domain --cli-input-json  file://./esdomain.json

# Wait for  Elastic Search cluster Creation to Complete
while ((aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --query 'DomainStatus.Processing') -eq $false) {
  Write-host "Waiting for  Elastic Search cluster to be created..."
  Start-Sleep -Seconds 60
}

# We need to retrieve the Fluent Bit Role ARN, Check Whether endpoint is created in ElasticSearch Console before running below commands
$FLUENTBIT_ROLE=(eksctl get iamserviceaccount --cluster $CLUSTER_NAME --namespace logging -o json | convertfrom-json).status.rolearn 

# Get the Elasticsearch Endpoint
$ES_ENDPOINT=(aws es describe-elasticsearch-domain --domain-name ${ES_DOMAIN_NAME} --output text --query "DomainStatus.Endpoint")

# Update the Elasticsearch internal database
$body = @"
[
  {
    "op": "add", "path": "/backend_roles", "value": ["${FLUENTBIT_ROLE}"]
  }
]
"@

(Invoke-Elasticsearch -Uri "https://${ES_ENDPOINT}/_opendistro/_security/api/rolesmapping/all_access?pretty" `
                     -Method PATCH `
                     -Body $body `
                     -Username $ES_DOMAIN_USER `
                     -Password $ES_DOMAIN_PASSWORD).content




# Rreplace real values in fluentbit-windows.yaml
(Get-Content ./templates/fluentbit-windows.yaml -Raw).Replace("__AWS_REGION__",$AWS_REGION).Replace("__ES_ENDPOINT__",$ES_ENDPOINT).Replace("__ACCOUNT_ID__",$ACCOUNT_ID).Replace("__AWS_ROLE_ARN__",$FLUENTBIT_ROLE).Replace("__INDEX_NAME__",$CLUSTER_NAME) | Set-Content ./fluentbit-windows.yaml

# Deploy Fluentbit

kubectl apply -f ./fluentbit-windows.yaml
