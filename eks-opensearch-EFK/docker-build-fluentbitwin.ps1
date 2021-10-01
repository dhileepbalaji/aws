param(
    [Parameter(Mandatory=$True, ValueFromPipeline=$false)]
    [System.String]
    $ACCOUNT_ID,
    [Parameter(Mandatory=$True, ValueFromPipeline=$false)]
    [System.String]
    $AWS_REGION,
    [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
    [System.String]
    $BUILDCONTEXT = "./templates",
    [Parameter(Mandatory=$False,ValueFromPipeline=$false)]
    [System.String]
    $DOCKERFILE = "./Dockerfile.windows"
)


Set-Location $BUILDCONTEXT

docker build -f $DOCKERFILE -t "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fluentbit_windows:latest" .

aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com" 

docker push "$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/fluentbit_windows:latest"

Set-Location $PSScriptRoot