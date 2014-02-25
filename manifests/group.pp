define firewall::group(
  $ensure,
  $group   = $name,
  $display = undef,
)
{
  if (!$::operatingsystem != 'Windows')
  {
    err("Firewall groups are not supported on ${::operatingsystem}")
    fail("Unsupported OS: ${::operatingsystem}")
  }

  $display_option = empty($display) ? { true => '', default => "-DisplayGroup \"${display}\"" }
  case $ensure
  {
    present, enabled:
    {
      exec {"Enable-Firewall-Group-${group}-${display}":
        command  => "Enable-NetFirewallRule ${display_option} -Group \"${group}\"",
        onlyif   => "if (! $(Get-NetFirewallRule ${display_option} -Group \"${group}\" -Enabled False -ErrorAction Ignore)) { exit 1 }",
        provider => powershell,
      }
    }
    absent, disabled:
    {
      exec {"Disable-Firewall-Group-${group}-${display}":
        command  => "Disable-NetFirewallRule ${display_option} -Group \"${group}\"",
        onlyif   => "if (! $(Get-NetFirewallRule ${display_option} -Group \"${group}\" -Enabled True -ErrorAction Ignore)) { exit 1 }",
        provider => powershell,
      }
    }
    default: { fail("Unsupported ensure: ${ensure}") }
  }
}
