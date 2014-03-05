define firewall::group(
  $ensure,
  $group   = $name,
  $display = undef,
)
{
  if ($::operatingsystem != 'windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  case $::operatingsystemrelease
  {
    '6.1.7601' : # Windows 7, 2008R2
    {
      $group_id=downcase($group)
      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Group-${name}":
            command  => "netsh advfirewall set ${group_id}profile state on",
            onlyif   => "if ((netsh advfirewall show ${group_id}profile state) | where {\$ -match '^State\s+OFF'} ) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          exec {"Disable-Firewall-Group-${name}":
            command  => "netsh advfirewall set ${group_id}profile state off",
            onlyif   => "if ((netsh advfirewall show ${group_id}profile state) | where {\$ -match '^State\s+ON'} ) { exit 1 }",
            provider => powershell,
          }
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
    default:      # Windows 8, 8.1, 2012, 2012R2
    {
      $display_option = empty($display) ? { true => '', default => "-DisplayGroup \"${display}\"" }
      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Group-${name}":
            command  => "Enable-NetFirewallRule ${display_option} -Group \"${group}\"",
            onlyif   => "if (! $(Get-NetFirewallRule ${display_option} -Group \"${group}\" -Enabled False -ErrorAction Ignore)) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          exec {"Disable-Firewall-Group-${name}":
            command  => "Disable-NetFirewallRule ${display_option} -Group \"${group}\"",
            onlyif   => "if (! $(Get-NetFirewallRule ${display_option} -Group \"${group}\" -Enabled True -ErrorAction Ignore)) { exit 1 }",
            provider => powershell,
          }
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
  }
}
