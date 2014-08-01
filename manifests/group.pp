define firewall::group(
  $ensure,
  $group   = $name,
  $display = undef,
  $profile = 'any',
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
      # TODO: Add support for profile argument like [ 'domain', 'public' ]
      case $profile
      {
        'domain':  { $profile_bit = '1' }
        'private': { $profile_bit = '2' }
        'public':  { $profile_bit = '4' }
        default:   { $profile_bit = '0x7FFFFFFF' }
      }

      case $ensure
      {
        present, enabled:
        {
          exec {"Enable-Firewall-Group-${name}":
            command  => "(New-Object -comObject HNetCfg.FwPolicy2).EnableRuleGroup(${profile_bit}, \"${group}\", \$true)",
            onlyif   => "if ((New-Object -comObject HNetCfg.FwPolicy2).IsRuleGroupEnabled(${profile_bit}, \"${group}\")) { exit 1 }",
            provider => powershell,
          }
        }
        absent, disabled:
        {
          exec {"Disable-Firewall-Group-${name}":
            command  => "(New-Object -comObject HNetCfg.FwPolicy2).EnableRuleGroup(${profile_bit}, \"${group}\", \$false)",
            onlyif   => "if (!(New-Object -comObject HNetCfg.FwPolicy2).IsRuleGroupEnabled(${profile_bit}, \"${group}\")) { exit 1 }",
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
