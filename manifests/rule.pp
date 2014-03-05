define firewall::rule(
  $ensure,
  $rule    = $name,
  $display = undef,
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
      $group_id=downcase($group)
      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Rule-${name}":
            command  => "netsh advfirewall firewall set rule name=\"${rule}\"",
            onlyif   => "if ((netsh advfirewall show rule name=\"${rule}\") | where {\$ -match '^Enabled\s+Yes'} ) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          #TODO: Code this
          err("Not coded yet")
          fail("Not coded yet")
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
    default:      # Windows 8, 8.1, 2012, 2012R2
    {
      $display_option = empty($display) ? { true => '', default => "-DisplayName \"${display}\"" }
      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Rule-${name}":
            command  => "Enable-NetFirewallRule ${display_option} -Name \"${rule}\"",
            onlyif   => "if ((Get-NetFirewallRule ${display_option} -Name \"${rule}\" -ErrorAction Ignore).Enabled) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
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
