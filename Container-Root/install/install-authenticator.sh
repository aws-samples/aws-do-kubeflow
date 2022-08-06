#!/bin/bash

curl -o aws-iam-authenticator https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator

chmod +x aws-iam-authenticator

mv ./aws-iam-authenticator /usr/local/bin

aws-iam-authenticator help

