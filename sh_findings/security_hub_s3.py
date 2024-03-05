import boto3
from openpyxl import Workbook

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
headers = ['Compliance Status', 'Severity', 'id', 'title', 'Account', 'ResourceType', 'ResourceId']
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
    account_it = finding['AwsAccountId']
    resource_type = finding['Resources'][0]['Type']
    resource_id = finding['Resources'][0]['Id']

    if resource_type=='AwsS3Bucket':
        row = [compliance_status, severity, ids, title, account_it, resource_type, resource_id]
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
        account_it = finding['AwsAccountId']
        resource_type = finding['Resources'][0]['Type']
        resource_id = finding['Resources'][0]['Id']
        if resource_type=='AwsS3Bucket':
            row = [compliance_status, severity, ids, title, account_it, resource_type, resource_id]
            ws.append(row)

wb.save("s3.xlsx")
