import boto3
import csv
from botocore.exceptions import ClientError
import json

# csv fields
field_names = ['ResourceArn', 'TagKey', 'TagValue']

# boto initialize
session = boto3.Session(
    aws_access_key_id='',
    aws_secret_access_key='')
region = 'ap-south-1'   # change region
restag = session.client('resourcegroupstaggingapi', region)
dynamodb = session.resource('dynamodb', region)


# function to write tags to csv
def writeToCsv(writer, tag_list):
    for resource in tag_list:
        print("Extracting tags for resource: " +
              resource['ResourceARN'] + "...")
        for tag in resource['Tags']:
            row = dict(
                ResourceArn=resource['ResourceARN'], TagKey=tag['Key'], TagValue=tag['Value'])
            writer.writerow(row)


# function to write tags to csv
def writeToJson(json_file, tag_list):
        json.dump(tag_list, json_file, indent=4)


# function to convert tag list to tag_dict
def tag_list_to_dict(tag_list):
    tags_dict = {}
    for tag in tag_list:
        tags_dict[tag['Key']] = tag['Value']
    return tags_dict


# function to merge dict
def merge_dict(dict1, dict2):
    return(dict2.update(dict1))


# export already tagged resources
def export_tagged_resources(json_file, TagFilters):
    with open('tagged-resources.csv', 'w') as csvfile:
        writer = csv.DictWriter(csvfile, quoting=csv.QUOTE_ALL,
                                delimiter=',', dialect='excel', fieldnames=field_names)
        writer.writeheader()
        response = restag.get_resources(
            ResourcesPerPage=50,
            TagFilters=TagFilters)
        print(response)
        writeToJson(json_file, response['ResourceTagMappingList'])
        while 'PaginationToken' in response and response['PaginationToken']:
            token = response['PaginationToken']
            response = restag.get_resources(
                TagFilters=TagFilters,
                ResourcesPerPage=50,
                PaginationToken=token)
            writeToJson(json_file, response['ResourceTagMappingList'])


# tag resources
def tag_resources(aws_resource_arn, tags):
    response = restag.tag_resources(
        ResourceARNList=[
            aws_resource_arn
        ],
        Tags=tags
    )


# function to read data from dynamodb
def dynamodb_read_tags(table_name, keys_dict):
    table = dynamodb.Table(table_name)

    try:
        response = table.get_item(
            Key=keys_dict)
    except ClientError as e:
        print(e.response['Error']['Message'])
    else:
        return response['Item']['tags']


# tag resources from dynamodb
def main():
    # get team names from dynamodb to tag the resources
    teams_table = dynamodb.Table('tags')  # change dynamodb table name here
    teams_table_response = teams_table.scan()
    teams = [i['team'] for i in teams_table_response['Items']]
    # teams override
    # teams = ["team1", "team2"]
    # loop through each team and export the resources matching the ABAC tag
    for team in teams:
        json_file = open('tagged-resources.json', 'w')
        # export all resources matching the below filter
        Tag_Filters = [
            {
            'Key': 'application',  # change key
            'Values': [team]       # change values
            }
        ]
        export_tagged_resources(json_file, Tag_Filters)
        json_file.close()

        # read json again to  tag the resources with new tags
        json_file = open('tagged-resources.json', 'r')
        # get data from dynamodb table
        keys_dict = {'team': team}  # change filter for dynamodb
        # dynamodb table name to fetch the tags
        dynamodb_table = "tags"  # change dynamodb table name here
        new_tags = dynamodb_read_tags(dynamodb_table, keys_dict)
        # loop through list of resources
        resources = json.load(json_file)
        for resource in resources:
            existing_tags = tag_list_to_dict(resource['Tags'])
            # merge old tags with new tags
            merge_dict(existing_tags, new_tags)
            tag_resources(resource['ResourceARN'], new_tags)


# run the script
main()


