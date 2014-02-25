define firewall::rule(
  $ensure,
  $rule    = $name,
  $display = undef,
)
{
  if (!$::operatingsystem != 'Windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  $display_option = empty($display) ? { true => '', default => "-DisplayName \"${display}\"" }
  case $ensure
  {
    present, enabled:
    {
      exec {"Enable-Firewall-Rule-${rule}-${display}":
        command  => "Enable-NetFirewallRule ${display_option} -Name \"${rule}\"",
        onlyif   => "if ((Get-NetFirewallRule ${display_option} -Name ${name} -ErrorAction Ignore).Enabled) { exit 1 }",
        provider => powershell,
      }
    }
    absent, disabled:
    {
      exec {"Disable-Firewall-Rule-${rule}-${display}":
        command  => "Disable-NetFirewallRule ${display_option} -Name \"${rule}\"",
        onlyif   => "if (!(Get-NetFirewallRule -name ${name} -ErrorAction Ignore).Enabled) { exit 1 }",
        provider => powershell,
      }
    }
    default: { fail("Unsupported ensure: ${ensure}") }
  }
}
