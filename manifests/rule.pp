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
