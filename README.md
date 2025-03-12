# terraform-aws-s3
This module is used to instantiate an AWS S3 Bucket based on [AWS Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html):
* Enforce encryption of data at rest using AWS Key Management Service (KMS)
* Enforce encryption of data in transit
* Consider using S3 Object Lock
* Implement least privilege access by blocking public access by default
* Enforce S3 Versioning
* Enable Amazon S3 server access logging

# Usage


