puppet-firewall
===============

Firewall management for Windows, Linux, and OS/X

Description
-----------

Unified types and rules to manage firewall.

Installation
------------

Via [puppet module](http://docs.puppetlabs.com/puppet/2.7/reference/modules_installing.html#installing-modules-1):

```bash
$ puppet module install xxxx
```

Via [librarian-puppet](https://github.com/rodjek/librarian-puppet), by adding the following line to your Puppetfile:

```
mod 'firewall', :git =>  'https://github.com/gildas/puppet-firewall.git'
```

Usage
-----

Load the base class:

```puppet
include firewall
```


