#
# Copyright 2015 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include ::openstack_integration
include ::openstack_integration::rabbitmq
include ::openstack_integration::mysql
include ::openstack_integration::keystone
include ::openstack_integration::glance
include ::openstack_integration::neutron
include ::openstack_integration::nova
include ::openstack_integration::cinder
include ::openstack_integration::ceilometer
include ::openstack_integration::aodh
include ::openstack_integration::trove
include ::openstack_integration::provision

# Aodh is not yet packaged in UCA, but only in RDO.
case $::osfamily {
  'Debian': {
    $aodh_enabled = false
  }
  'RedHat': {
    $aodh_enabled = true
  }
  default: {
    fail("Unsupported osfamily (${::osfamily})")
  }
}

class { '::openstack_integration::tempest':
  cinder     => true,
  ceilometer => true,
  aodh       => $aodh_enabled,
  trove      => true,
}
