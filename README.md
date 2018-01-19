
# aws_owpe_policysign

OpsWorks Puppet Enterprise (OWPE) is an AWS service offering that provisions PE masters on demand. OWPE Policy Sign module turns on auto signing feature and provides default policy script.

#### License
This library is licensed under the Apache 2.0 License.

#### Table of Contents

1. [Description](#description)
2. [Setup](#setup)
    * [What owpepolicysign affects](#what-owpepolicysign-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

OpsWorks Puppet Enterprise (OWPE) is an AWS service offering that provisions PE masters on demand.  OWPE Policy Sign module turns on auto signing feature with a default policy script.

## Setup

### What owpepolicysign affects

The following files will be impacted:
* /etc/puppetlabs/puppet/puppet.conf
* /opt/puppetlabs/autosign/autosign.sh
* /opt/puppetlabs/server/data/puppetserver/.aws/config
* /opt/puppetlabs/server/data/puppetserver/.aws/credentials

Furthermore, the following packages will be installed if absent:
* aws-cli
* jq
NOTE: yum repository 'amzn-main/2017.09' must be present in order for these packages to be installed

### Setup Requirements

From PE console 'allow_unauthenticated_ca' config must be set to 'true' under puppet_enterprise::profile::master class

## Usage
NOTE: This module requires access to puppetlabs-stdlib module. Assuming that the modules are available under /home/ec2-user directory, one can run this module as below:

puppet apply  --modulepath /home/ec2-user npark-owpepolicysign/examples/init.pp

## Reference

https://aws.amazon.com/opsworks/puppetenterprise/
http://docs.aws.amazon.com/opsworks/latest/userguide/opspup-unattend-assoc.html
https://puppet.com/docs/puppet/5.3/ssl_autosign.html

## Limitations

Currently there is no integration with associate node API in AWS
