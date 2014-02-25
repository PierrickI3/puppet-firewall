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
