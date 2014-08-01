define firewall::profile(
  $ensure,
  $profile = $name,
)
{
  if ($::operatingsystem != 'windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  case $::operatingsystemrelease
  {
    '6.1.7601', '2008 R2' : # Windows 7, 2008R2
    {
      $profile_id=downcase($profile)
      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Profile-${name}":
            command  => "netsh advfirewall set ${profile_id}profile state on",
            onlyif   => "if ((netsh advfirewall show ${profile_id}profile state) | where {\$_ -match '^State\s+ON'} ) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          exec {"Disable-Firewall-Profile-${name}":
            command  => "netsh advfirewall set ${profile_id}profile state off",
            onlyif   => "if ((netsh advfirewall show ${profile_id}profile state) | where {\$_ -match '^State\s+OFF'} ) { exit 1 }",
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
        present, enabled:
        {
          exec {"Enable-Firewall-Profile-${name}":
            command  => "Set-NetFirewallProfile -Profile \"${profile}\" -Enabled True",
            onlyif   => "if ((Get-NetFirewallProfile -Profile \"${profile}\").Enabled) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          exec {"Disable-Firewall-Profile-${name}":
            command  => "Set-NetFirewallProfile -Profile \"${profile}\" -Enabled False",
            onlyif   => "if (!(Get-NetFirewallProfile -Profile \"${profile}\").Enabled) { exit 1 }",
            provider => powershell,
          }
        }
        default: { fail("Unsupported ensure: ${ensure}") }
      }
    }
  }
}
