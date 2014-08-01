define firewall::rule(
  $ensure,
  $rule           = $name,
  $create         = false, # true if the rule should be created as needed
  $display        = undef,
  $description    = undef,
  $action         = undef,
  $group          = undef,
  $direction      = undef,
  $profile        = 'any',
  $protocol       = undef,
  $local_address  = undef,
  $local_port     = undef,
  $remote_address = undef,
  $remote_port    = undef,
  $program        = undef,
  $service        = undef,
  $throttle_limit = undef,
)
{
  if ($::operatingsystem != 'windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  #TODO: Use profiles!
  case $::operatingsystemrelease
  {
    '6.1.7601' : # Windows 7, 2008R2
    {
      case $ensure
      {
        present, enabled, on, yes:
        {
          exec {"Enable-Firewall-Rule-${name}":
            command  => "netsh advfirewall firewall set rule name=\"${rule}\" profile=\"${profile}\" new enable=yes",
            onlyif   => "if ((netsh advfirewall firewall show rule name=\"${rule}\" profile=\"${profile}\") | where {\$_ -match '^Enabled:\\s+Yes'} ) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled, off, no:
        {
          exec {"Disable-Firewall-Rule-${name}":
            command  => "netsh advfirewall firewall set rule name=\"${rule}\" profile=\"${profile}\" new enable=no",
            onlyif   => "if ((netsh advfirewall firewall show rule name=\"${rule}\" profile=\"${profile}\") | where {\$_ -match '^Enabled:\\s+No'} ) { exit 1 }",
            provider => powershell,
          }
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
    default:      # Windows 8, 8.1, 2012, 2012R2
    {
      case $ensure
      {
        absent, uninstalled:
        {
        }
        present, enabled, on, yes:
        {
          if ($create) { validate_re($action,    ['^(?i)(allow|block)$'])}
          if ($create) { validate_re($direction, ['^(?i)(inbound|outdbound)$'])}
          #TODO: Validate Profile: value,value,value or value, valun in Any|Public|Domain|Private|NotApplicable

          $display_option        = empty($display)        ? { true => '', default => "-DisplayName \"${display}\"" }
          $direction_option      = empty($direction)      ? { true => '', default => "-Direction ${direction}" }
          $description_option    = empty($description)    ? { true => '', default => "-Description \"${description}\"" }
          $action_option         = empty($action)         ? { true => '', default => "-Action ${action}" }
          $group_option          = empty($group)          ? { true => '', default => "-group ${group}" }
          $protocol_option       = empty($protocol)       ? { true => '', default => "-Protocol \"${protocol}\"" }
          $local_address_option  = empty($local_address)  ? { true => '', default => "-LocalAddress ${local_address}" }
          $local_port_option     = empty($local_port)     ? { true => '', default => "-LocalPort ${local_port}" }
          $remote_address_option = empty($remote_address) ? { true => '', default => "-RemoteAddress ${remote_address}" }
          $remote_port_option    = empty($remote_port)    ? { true => '', default => "-RemotePort ${remote_port}" }
          $program_option        = empty($program)        ? { true => '', default => "-Program \"${program}\"" }
          $profile_option        = empty($profile)        ? { true => '', default => "-Profile ${profile}" }
          $service_option        = empty($service)        ? { true => '', default => "-Service ${service}" }
          $throttle_limit_option = empty($throttle_limit) ? { true => '', default => "-ThrottleLimit ${throttle_limit}" }

          $create_options = "${display_option} ${description_option} ${group_option} ${profile_option} ${protocol_option} ${local_address_option} ${local_port_option} ${remote_address_option} ${remote_port_option} ${program_option} ${service_option} ${direction_option} ${action_option}"

          exec {"Create-Firewall-Rule-${name}":
            command  => "New-NetFirewallRule -Name \"${rule}\" ${create_options}",
            onlyif   => "if (Get-NetFirewallRule -Name \"${rule}\" -ErrorAction Ignore) { exit 1 }",
            provider => powershell,
          }

          exec {"Enable-Firewall-Rule-${name}":
            command  => "Enable-NetFirewallRule -Name \"${rule}\"",
            onlyif   => "if ((Get-NetFirewallRule -Name \"${rule}\" -ErrorAction Ignore).Enabled) { exit 1 }",
            provider => powershell,
            require  => Exec["Create-Firewall-Rule-${name}"],
          }
        }
        disabled, off, no:
        {
          exec {"Disable-Firewall-Rule-${name}":
            command  => "Disable-NetFirewallRule ${display_option} -Name \"${rule}\"",
            onlyif   => "if (!(Get-NetFirewallRule -name \"${rule}\" -ErrorAction Ignore).Enabled) { exit 1 }",
            provider => powershell,
          }
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
  }
}
