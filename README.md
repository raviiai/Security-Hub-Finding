# Security-Hub-Finding

1=>  S3.9 bucket server access logging should be enabled 

2=>  SNS topics should be encrypted at-rest using AWS KMS 

3=>  S3.11 S3 bucket should have event notifications enabled 

4=>  2.1.2 Ensure S3 Bucket Policy is set to deny HTTP requests 

5=>  S3.5 S3 buckets should require requests to use Secure Socket Layer 

6=>  SNS.2 Logging of delivery status should be enabled for notification messages sent to a topic 

7=>  S3.10 S3 buckets with versioining enabled should have lifecycle policies configured  

8=>  KMS.2 IAM principals should not have IAM inline policies that allow decryption actions on all KMS keys

9=>  APIGateway.4 API Gateway should be associated with a WAF Web ACL  

10=> ECR.2 ECR private repositories should have tag immutability configured

11=> KMS.1 IAM customer managed policies should not allow decryption actions on all KMS keys

12=> APIGateway.2 API Gateway REST API stages should be configured to use SSL certificates for backend authenticatin

13=> SSM.1 EC2 instances should be managed by AWS Systems Manager

14=> DynamoDB.6 DynamoDB tables should habe deletion protection enabled