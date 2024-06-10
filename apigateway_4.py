import boto3
from openpyxl import Workbook
import json

######################################
## Function to Fetch Tags
######################################

def fetch_detail_api_gateway(stage_arn, restApiId, stageName):
    client = boto3.client('apigateway')
    try:
        response = client.get_stage(
            restApiId=restApiId, 
            stageName=stageName  
        )
        # Fetch more details like tags
        tags_response = client.get_tags(resourceArn=stage_arn)
        return json.dumps(tags_response['tags'])
    except Exception as e:
        print("Error:", e)
    

######################################
## Code Starts here
######################################

securityhub = boto3.client('securityhub')
s3 = boto3.resource('s3')
_filter = {
    'ComplianceStatus': [
        {
            'Value': 'FAILED',
            'Comparison': 'EQUALS'
        }
    ],
    'RecordState': [
        {
            'Value': 'ACTIVE',
            'Comparison': 'EQUALS'
        }
    ],
    'GeneratorId': [
        {
            'Value': 'aws-foundation',
            'Comparison': 'PREFIX'
        }
    ],
}
_sort = [
    {
        'Field': 'ComplianceStatus',
        'SortOrder': 'desc'
    },
    {
        'Field': 'SeverityNormalized',
        'SortOrder': 'desc'
    }
]

wb = Workbook()
ws = wb.active
headers = ['Compliance Status', 'Severity', 'id', 'title', 'Account', 'ResourceType', 'ResourceId', 'Tags']
ws.append(headers)

MAX_ITEMS = 100

result = securityhub.get_findings(
    Filters=_filter,
    SortCriteria=_sort,
    MaxResults=MAX_ITEMS
)

findings = result['Findings']

for finding in findings:
    compliance_status = finding['Compliance']['Status']
    severity = finding['Severity']['Label']
    ids = finding['ProductFields']['ControlId']
    title = finding['Title']
    account_id = finding['AwsAccountId']
    resource_type = finding['Resources'][0]['Type']
    resource_id = finding['Resources'][0]['Id']
    
    
    if ids=="APIGateway.4":
        stage_arn = resource_id
        stageName = finding['Resources'][0]['Details']['AwsApiGatewayStage']['StageName']
        parts = stage_arn.split('/')
        rest_api_id = parts[2]
        tags = fetch_detail_api_gateway(resource_id, rest_api_id, stageName)
 
        row = [compliance_status, severity, ids, title, account_id, resource_type, resource_id, tags]
        ws.append(row)

while 'NextToken' in result:
    result = securityhub.get_findings(
        Filters=_filter,
        SortCriteria=_sort,
        MaxResults=MAX_ITEMS,
        NextToken=result['NextToken']
    )
    findings = result['Findings']
    for finding in findings:
        compliance_status = finding['Compliance']['Status']
        severity = finding['Severity']['Label']
        ids = finding['ProductFields']['ControlId']
        title = finding['Title']
        account_id = finding['AwsAccountId']
        resource_type = finding['Resources'][0]['Type']
        resource_id = finding['Resources'][0]['Id']

        if ids == "APIGateway.4":
            stage_arn = resource_id
            stageName = finding['Resources'][0]['Details']['AwsApiGatewayStage']['StageName']
            parts = stage_arn.split('/')
            rest_api_id = parts[2]
            tags = fetch_detail_api_gateway(resource_id, rest_api_id, stageName)

            row = [compliance_status, severity, ids, title, account_id, resource_type, resource_id, tags]
            ws.append(row)

wb.save("securityhub_findings.xlsx")




