define firewall::profile(
  $ensure,
  $profile = $name,
  $display = undef,
)
{
  if (!$::operatingsystem != 'windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  $display_option = empty($display) ? { true => '', default => "-DisplayGroup \"${display}\"" }
  case $ensure
  {
    present, enabled:
    {
      exec {"Enable-Firewall-Profile-${profile}":
        command  => "Set-NetFirewallProfile -Profile ${profile} -Enabled True",
        onlyif   => "if ((Get-NetFirewallProfile -Profile ${profile}).Enabled) { exit 1 }",
        provider => powershell,
      }
    }
    absent, disabled:
    {
      exec {"Disable-Firewall-Profile-${profile}":
        command  => "Set-NetFirewallProfile -Profile ${profile} -Enabled False",
        onlyif   => "if (!(Get-NetFirewallProfile -Profile ${profile}).Enabled) { exit 1 }",
        provider => powershell,
      }
    }
    default: { fail("Unsupported ensure: ${ensure}") }
  }
}
