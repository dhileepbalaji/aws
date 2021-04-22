import boto3
import yaml
# Used to handle spaces in filenames -> unquote_plus
from urllib.parse import unquote_plus

def safe_yaml_loader(yamlfile, loaders=[yaml.FullLoader, yaml.Loader, None]):
    """
    Try different YAML loaders
    """
    json = None
    for loader in loaders:
        with open(yamlfile) as fp:
            try:
                json = yaml.load(fp, Loader=loader)
                break
                print(loader)
            except:
                pass

    if json is None:
        raise IOError('Failed to load {0} with {1}'.format(file, loaders))

    return json


def make_tags(tags):
    tag_list = []
    for k, v in tags.items():
        tag_list.append({'Key': str(k),
                         'Value': str(v) if v is not None else '---'})

    return {'TagSet': tag_list}


def put_get_tags(boto_context, bucket, s3object, tag_set):
    try:
        print('put tags for Bucket: {0} File : {1} '.format(bucket,s3object))
        print('Tags:{0}'.format(tag_set))
        response = boto_context.put_object_tagging(Bucket=bucket,
                                                   Key=unquote_plus(s3object),
                                                   Tagging=tag_set)
    except Exception as e:
        print('put tags %s failed' % e)
        return -1
    response = boto_context.get_object_tagging(Bucket=bucket, Key=unquote_plus(s3object))
    print('get tags returned %s' % response)
    print('Tagging Completed Successfully')
    return 0


# boto3 S3 initialization
s3_client = boto3.client("s3")


def lambda_handler(event, context):
    # Bucket Name from event
    bucket_name = event['Records'][0]['s3']['bucket']['name']
    # Filename of object (with path)
    file_key_name = event['Records'][0]['s3']['object']['key']
    # Load config file
    config = safe_yaml_loader("config.yaml")
    # iterate through projects to match paths
    for project in config["projects"].keys():
        if any(map(file_key_name.__contains__, config["projects"][project]["paths"])):
            # if any match found, use the tags from that project
            put_get_tags(s3_client,bucket_name, file_key_name, make_tags(config["projects"][project]["tags"]))
            break
    else:
        print("No matching projects for Bucket: {} File: {}".format(bucket_name, file_key_name))
