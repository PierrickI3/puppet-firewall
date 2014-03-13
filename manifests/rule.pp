define firewall::rule(
  $ensure,
  $rule    = $name,
  $display = undef,
  $profile = 'any',
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
      $display_option = empty($display) ? { true => '', default => "-DisplayName \"${display}\"" }
      case $ensure
      {
        present, enabled, on, yes:
        {
          exec {"Enable-Firewall-Rule-${name}":
            command  => "Enable-NetFirewallRule ${display_option} -Name \"${rule}\"",
            onlyif   => "if ((Get-NetFirewallRule ${display_option} -Name \"${rule}\" -ErrorAction Ignore).Enabled) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled, off, no:
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
