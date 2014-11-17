puppet-firewall
===============

Firewall management for Windows, Linux, and OS/X

Note: At the moment, **only** Windows (7, 2008R2, 8, 8.1, 2012R2) is implemented.

Description
-----------

Unified types and rules to manage firewall.

Installation
------------

Via [puppet module](http://docs.puppetlabs.com/puppet/2.7/reference/modules_installing.html#installing-modules-1):

```bash
$ puppet module install gildas-firewall
```

Via [librarian-puppet](https://github.com/rodjek/librarian-puppet) or [r10k](https://github.com/adrienthebo/r10k), by adding the following line to your Puppetfile:

```
mod 'gildas/firewall'
```

Usage
-----

Load the base class:

```puppet
include firewall
```

By default, firewall resources that are declared in hiera will be automatically loaded and created.
If you do not want this behavior, configure the base class as follows:

```puppet
class {'firewall':
  hiera_loader => false
}
```

Configuring the firewall
------------------------

To configure firewall rules, simply instanciate resources in you manifests, e.g.:

```puppet
  firewall::rule { 'SQLServer':
    rule        => 'SQLServer-Instance-In-TCP',
    ensure      => enabled,
    create      => true,
    display     => 'SQLServer Instance (TCP-In)',
    description => 'Inbound Rule to access the SQLServer instance [TCP 1433]',
    action      => 'Allow',
    direction   => 'Inbound',
    protocol    => 'TCP',
    local_port  => 1433,
  }
```
This resource creates a rule (as needed) to allow incoming SQL Server communication.

If a rule should already exist in Windows and just  be enabled or disabled, you can do the following:

```puppet
  firewall::rule { 'WinRM':
    rule   => 'WINRM-HTTP-In-TCP-NoScope',
    ensure => enabled,
  }
```

**Note:** It is not possible to delete rules yet.

Similarly, it is possible to enable firewall groups:

```puppet
  firewall::group { 'File and Printer Sharing':
    group  => '@FirewallAPI.dll,-28502',
    ensure => enabled,
  }
```
**Note:** It is not possible to create/delete groups yet.

Finally, managing firewall profiles:

```puppet
  firewall::profile { "Private":
    profile => "Private",
    ensure  => enabled,
  }
```

Hiera configuration
-------------------

If you use hiera, the puppet class firewall will search for firewall entries and create resources.
At the moment, the following firewall entries are available:
- firewall::profiles
- firewall::groups
- firewall::rules

For example, to configure the Remote Desktop group in Windows, add the following to you hiera database:

```json
{
  ...

  "firewall::groups": {
    "Remote Desktop":
    {
      "group":  "@FirewallAPI.dll,-28752",
      "ensure": "enabled"
    }
  },

  ...
}
```

Or to accept WinRM connections over HTTP on Windows 8/8.1:

```json
{
  ...

  "firewall::rules": {
    "WINRM-HTTP-In-TCP-NoScope":
    {
      "rule": "WINRM-HTTP-In-TCP-NoScope",
      "ensure": "enabled"
    },
  
  ...
}
```
