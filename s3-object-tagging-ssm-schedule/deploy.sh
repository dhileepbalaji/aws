DIRNAME=$(dirname "$0")
TEAM_NAME="test"
PROFILE="default"
S3_BUCKET=""
STACK_NAME="test"
aws cloudformation package  --template-file $DIRNAME/template.yaml --s3-bucket $S3_BUCKET --s3-prefix $TEAM_NAME/team --output-template-file $DIRNAME/output/packaged-template.yaml


echo "Checking if stack exists ..."
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME; then
  echo -e "Stack does not exist, creating ..."
  aws cloudformation create-stack \
    --stack-name $STACK_NAME \
    --template-body file://$DIRNAME/output/packaged-template.yaml \
    --capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_AUTO_EXPAND" 

  echo "Waiting for stack to be created ..."
  aws cloudformation wait stack-create-complete  \
    --stack-name $STACK_NAME
else
  echo -e "Stack exists, attempting update ..."

  set +e
  update_output=$( aws cloudformation update-stack \
    --stack-name $STACK_NAME \
    --template-body file://$DIRNAME/output/packaged-template.yaml \
    --capabilities "CAPABILITY_NAMED_IAM" "CAPABILITY_AUTO_EXPAND" 2>&1)
  status=$?
  set -e

  echo "$update_output"
fi