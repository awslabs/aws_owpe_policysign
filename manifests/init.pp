#
# Copyright 2017-2018 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at
#
#    http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
#

class owpepolicysign (
  $packages       = lookup({'name' => 'owpepolicysign::packages', 'default_value' => {}, 'merge' => {'strategy' => 'deep', 'merge_hash_arrays' => true}}),   # lint:ignore:140chars
  $autosignconfig = lookup({'name' => 'owpepolicysign::autosign', 'default_value' => {}, 'merge' => {'strategy' => 'deep', 'merge_hash_arrays' => true}}),   # lint:ignore:140chars
  $puppetconf     = lookup({'name' => 'owpepolicysign::puppetconf', 'default_value' => {}, 'merge' => {'strategy' => 'deep', 'merge_hash_arrays' => true}}), # lint:ignore:140chars
  $awsconfig      = lookup({'name' => 'owpepolicysign::awsconfig', 'default_value' => {}, 'merge' => {'strategy' => 'deep', 'merge_hash_arrays' => true}})   # lint:ignore:140chars
) {
  # Setup packages
  each($packages) | $package | {
    package { $package:
      ensure =>  present,
    }
  }

  #Setup AWS CLI config structure for pe-puppet user
  $awsconfigdir = $awsconfig['configdir']
  $awsconfigconf = $awsconfig['configfile']
  $awsconfigcred = $awsconfig['credentials']
  $awsconfigfileuser = $awsconfig['user']
  $awsconfigfilegroup = $awsconfig['group']
  $awsconfigfileperm = $awsconfig['mode']
  $awsconfigdefaultoutput = $awsconfig['defaultoutput']
  $awsconfigdefaultregion = $awsconfig['defaultregion']
  $awsconfigaccessid = $awsconfig['accessid']
  $awsconfigaccesskey = $awsconfig['accesskey']
  file { 'pe-puppet AWS CLI root dir':
    ensure => directory,
    path   => $awsconfigdir,
    owner  => $awsconfigfileuser,
    group  => $awsconfigfilegroup,
    mode   => '0700',
  }
  -> file { 'pe-puppet AWS CLI config file':
    ensure  => present,
    path    => "${awsconfigdir}/${awsconfigconf}",
    owner   => $awsconfigfileuser,
    group   => $awsconfigfilegroup,
    mode    => $awsconfigfileperm,
    content => epp("${module_name}/awscliconfig.epp",{output=>$awsconfigdefaultoutput,region=>$awsconfigdefaultregion}),
  }
  -> file { 'pe-puppet AWS CLI credential file':
    ensure  => present,
    path    => "${awsconfigdir}/${awsconfigcred}",
    owner   => $awsconfigfileuser,
    group   => $awsconfigfilegroup,
    mode    => $awsconfigfileperm,
    content => epp("${module_name}/awsclicred.epp",{accessid=>$awsconfigaccessid,accesskey=>$awsconfigaccesskey}),
  }

  # Setup autosign hierarchy
  $autosigndir = $autosignconfig['configdir']
  $autosignscript = $autosignconfig['script']
  $autosignfileuser = $autosignconfig['user']
  $autosignfilegroup = $autosignconfig['group']
  $autosignfileperm = $autosignconfig['mode']
  file { 'Auto sign root directory':
    ensure => directory,
    path   => $autosigndir,
    owner  => $autosignfileuser,
    group  => $autosignfilegroup,
    mode   => $autosignfileperm,
  }
  -> file { 'Auto sign script':
    ensure  => present,
    path    => "${autosigndir}/${autosignscript}",
    owner   => $autosignfileuser,
    group   => $autosignfilegroup,
    mode    => $autosignfileperm,
    content => epp("${module_name}/autosign.sh.epp"),
  }

  # Alter puppet.conf so it points to autosign.sh
  $puppetconffile = $puppetconf['conffile']
  $puppetconfentry = $puppetconf['autosignentry']
  file_line { 'Delete autosign entry':
    ensure => absent,
    path   => $puppetconffile,
    line   => $puppetconfentry,
  }
  -> file_line { 'Add autosign entry':
    ensure => present,
    path   => $puppetconffile,
    match  => '\[main\]',
    line   => "[main]\n${puppetconfentry}",
  }

}
