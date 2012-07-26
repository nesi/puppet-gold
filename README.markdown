# puppet-gold
=============

A Puppet module for installing the GOLD Accounting Software for HPC systems.

* http://www.adaptivecomputing.com/products/open-source/gold/

# To install into puppet

Clone into your puppet configuration in your `puppet/modules` directory:

 git clone git://github.com/nesi/puppet-gold.git gold

Or if you're managing your Puppet configuration with git, in your `puppet` directory:

		git submodule add git://github.com/nesi/puppet-gold.git modules/gold --init --recursive
		cd modules/gold
		git checkout master
		git pull
		cd ../..
		git commit -m "added gold submodule from https://github.com/nesi/puppet-gold"

It might seem bit excessive, but it will make sure the submodule isn't headless...

# Requirements

This module requires the NeSI Puppet modules for Perl and PostgreSQL.

* https://github.com/nesi/puppet-perl
* https://github.com/nesi/puppet-postgresql

It also requires Apache with mod_ssl.

# Using 

## Parameters

# To do...

# Credits

Written by Aaron Hicks (hicksa@landcareresearch.co.nz) for the New Zealand eScience Infrastructure.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons Licence" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>