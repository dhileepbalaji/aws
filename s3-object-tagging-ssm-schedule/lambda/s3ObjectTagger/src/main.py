import boto3
# Used to handle spaces in filenames -> unquote_plus
from urllib.parse import unquote_plus


def make_tags(tag_list):
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
    #response = boto_context.get_object_tagging(Bucket=bucket, Key=unquote_plus(s3object))
    #print('get tags returned %s' % response)
    print('Tagging Completed Successfully')
    return 0


def generate_ssm_paths(ssm_client,ssm_path):
    ssm_paths = ssm_client.get_parameters_by_path(Path=ssm_path, Recursive=True)
    ssm_paths_dict = {}
    for path in ssm_paths['Parameters']:
        ssm_param_name = path['Name'].lstrip(ssm_path).split('/')[0]
        dict_key = ssm_param_name + "/"
        dict_value = path['Name']
        if dict_key not in ssm_paths_dict:
            ssm_paths_dict[dict_key] = {}
            ssm_paths_dict[dict_key]['ssmparam'] = dict_value
            # get ssm tags
            tags = ssm_client.list_tags_for_resource(ResourceType='Parameter', ResourceId=path['Name'])
            ssm_paths_dict[dict_key]['tags'] = tags['TagList']
    return ssm_paths_dict


def tag_bucket_objects(s3_client,paginator,bucket_name, ssm_paths):
    # Filename of object (with path)
    getFiles = paginator.paginate(Bucket=bucket_name)
    # iterate through projects to match paths
    for page in getFiles:
        if "Contents" in page:
            for s3key in page["Contents"]:
                for dict_key, dict_value in ssm_paths.items():
                    # if any match found, use the tags from that ssm param
                    if dict_key in s3key['Key']:
                        put_get_tags(s3_client, bucket_name, s3key['Key'],
                                     make_tags(ssm_paths[dict_key]["tags"]))
                        break
                else:
                    pass
                    # print("No matching Tags for Bucket: {} File: {} ".format(bucket_name,s3key['Key']))



def lambda_handler(event,context):
    # boto3 initialization
    ssm_client = boto3.client('ssm')
    ssm_path = '/SDLF/KMS'
    # generate dict from ssm store to match against s3 objects
    ssm_paths_to_match = generate_ssm_paths(ssm_client,ssm_path)
    # connect to s3 and tag objects based on /SDLF/S3 ssm store buckets
    s3_client = boto3.client("s3")
    paginator = s3_client.get_paginator('list_objects_v2')
    buckets_path = '/SDLF/S3'
    buckets = ssm_client.get_parameters_by_path(Path=buckets_path, Recursive=True)
    # Loop through buckets and tag the s3 objects.
    for bucket in buckets['Parameters']:
        tag_bucket_objects(s3_client, paginator, bucket['Value'], ssm_paths_to_match)







