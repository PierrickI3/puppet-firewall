# == Class: firewall
#
# Loads the basic software needed to run the firewall.
#
# === Parameters
#
# === Variables
#
# === Examples
#
#  include firewall
#
# === Authors
#
# Author Name <gildas@breizh.org>
#
# === Copyright
#
# Copyright 2014 Gildas CHERRUEL
#
class firewall {

  # Enable/Disable firewall profiles via hiera
  $profiles = hiera_array('firewall::profiles', [])
  if (!empty($profiles))
  {
    notice(" Checking firewall profiles: ${profiles}")
    $profile_default = {
      ensure => enabled,
    }

    create_resources(firewall::profile, $profiles, $profile_default)
  }

  # Enable/Disable firewall groups via hiera
  $groups = hiera_array('firewall::groups', [])
  if (!empty($groups))
  {
    notice(" Checking firewall groups: ${groups}")
    $group_default = {
      ensure => enabled,
    }

    create_resources(firewall::group, $groups, $group_default)
  }

  # Enable/Disable firewall rules via hiera
  $rules = hiera_array('firewall::rules', [])
  if (!empty($rules))
  {
    notice(" Checking firewall rules: ${rules}")
    $rule_default = {
      ensure => enabled,
    }

    create_resources(firewall::rule, $rules, $rule_default)
  }
}
