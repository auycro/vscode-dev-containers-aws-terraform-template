#!/usr/bin/env bash
#-------------------------------------------------------------------------------------------------------------
# Copyright (c) Auycro. All rights reserved.
# Licensed under the MIT License.
#-------------------------------------------------------------------------------------------------------------
# Syntax: ./aws-iam-authenticator-debian.sh

# https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
AWS_IAM_AUTHENTICATOR_DOWNLOAD_URI="https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/amd64/aws-iam-authenticator"

set -e

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Install aws-iam-authenticator if not already installed
if type aws-iam-authenticator > /dev/null 2>&1; then
    echo "aws-iam-authenticator already installed."
else
    echo "(*) aws-iam-authenticator..."
    curl -fsSL "${AWS_IAM_AUTHENTICATOR_DOWNLOAD_URI}" -o /usr/local/bin/aws-iam-authenticator
    chmod +x /usr/local/bin/aws-iam-authenticator
fi

echo -e "\nDone!"