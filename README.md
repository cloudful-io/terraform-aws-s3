# terraform-aws-s3
This Terraform module is used to instantiate an AWS S3 Bucket based on [AWS Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html):
* Enforce encryption of data at rest using AWS Key Management Service (KMS)
* Enforce encryption of data in transit
* Consider using S3 Object Lock
* Implement least privilege access by blocking public access by default
* Enforce S3 Versioning
* Enable Amazon S3 server access logging

# Usage
To instantiate an AWS S3 bucket based on the AWS Security Best Practices, you simply need to provide a unique bucket name.  Bucket names must be unique across all AWS accounts in all the AWS Regions within a partition. A partition is a grouping of Regions. Since server access logging is enabled by default, you must either specify the name of an existing S3 bucket where the logs will be stored, or specify to have a new bucket created by setting `create_logging_bucket` to `true`.  If the S3 bucket is intended to be used for static website hosting, the following will happen:
- Encryption of data at rest will use Amazon S3 Managed Keys (SSE-S3)
- Encryption of data in transit will not be enforced
- Public access will be enabled
- A bucket policy will be created to allow anyone to perform `GetObject` on any S3 objects

# References
- [AWS Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)

# Requirements
| Name      | Version   |
| --------- | --------- |
| terraform | >= 1.3.0  |
| aws       | >= 4.64.0 |

# Providers
| Name      | Version   |
| --------- | --------- |
| aws       | >= 4.64.0 |