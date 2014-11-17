# == Class: firewall
#
# Loads the basic software needed to run the firewall.
#
# === Parameters
# [*hiera_loader*]
#   If true, this module will query hiera and create profile, groupsl, and rules resources.
#   Default: true
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
class firewall (
  $hiera_loader = true
)
{
  if ($hiera_loader)
  {
    include firewall::hiera_loader
  }
}
