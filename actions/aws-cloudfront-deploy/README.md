## Description

Action to upload files to S3 and create a Cloudfront cache invalidation

## Inputs

| name | description | required | default |
| --- | --- | --- | --- |
| `aws-role-arn` | <p>The AWS Role to assume and execute actions in the pipeline that interact with AWS services</p> | `true` | `""` |
| `aws-region` | <p>The region in AWS that we will be working in</p> | `false` | `us-east-1` |
| `aws-session-name` | <p>The AWS session name to use when assuming the AWS Role</p> | `false` | `github-action-cloudfront` |
| `path` | <p>Path to be copied to AWS S3</p> | `false` | `.` |
| `s3-bucket-name` | <p>Name of AWS S3 bucket</p> | `true` | `""` |
| `s3-bucket-domain` | <p>Domain of AWS S3 bucket</p> | `true` | `""` |


## Runs

This action is a `composite` action.

## Usage

```yaml
- uses: ***PROJECT***@***VERSION***
  with:
    aws-role-arn:
    # The AWS Role to assume and execute actions in the pipeline that interact with AWS services
    #
    # Required: true
    # Default: ""

    aws-region:
    # The region in AWS that we will be working in
    #
    # Required: false
    # Default: us-east-1

    aws-session-name:
    # The AWS session name to use when assuming the AWS Role
    #
    # Required: false
    # Default: github-action-cloudfront

    path:
    # Path to be copied to AWS S3
    #
    # Required: false
    # Default: .

    s3-bucket-name:
    # Name of AWS S3 bucket
    #
    # Required: true
    # Default: ""

    s3-bucket-domain:
    # Domain of AWS S3 bucket
    #
    # Required: true
    # Default: ""
```



