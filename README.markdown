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

# Prerequsities

Using the NeSI PostgreSQL module, define a PostgreSQL database on the GOLD server with localhost, IP address, and fully qualified domain name as listen addresses

		class{'postgresql::server':
				listen_addresses	=> "localhost,${ipaddress},${fqdn}",
		}

# Using the gold class 

A recommended GOLD install

		class{'gold':
					web_ui				=> true,
					httpd					=> 'httpd',
					country				=> 'NZ',
					state					=> 'North Island',
					city					=> 'Auckland',
					organisation	=> 'New Zealand eScience Infrastructure',
					ou 						=> 'NeSI@Auckland',
					admin_email		=> 'support@nesi.org.nz',
		}

## Parameters

* **version**: Sets the version of GOLD to be installed, defaults to '2.2.0.4'
* **web_ui**: If 'true' the GOLD Web UI will be installed, defaults to 'false'
* **httpd**: The name of the HTTP daemon running, defaults to 'apache2'. This must be the service name as defined in Puppet.
* **pass_phrase**: Setts the password of the gold database user, defaults to 'changeme'. Using the default value is *not* recommended.
* **psql_server**: Specifies the host name of the PostgreSQL server for the gold database, defaultst to 'false' indicating the server is the localhost.
* **db_user**: The PostgreSQL database user name, defaults to 'gold'
* **db_name**: The PostgreSQL database name, defaults to 'gold'
* **country**: The two letter country code for the GOLD self signed certificate, defaults to "". Using the default value is *not* recommended.
* **state**: The state for the GOLD self signed certificate, defaults to "". Using the default value is *not* recommended.
* **city**:  The city value for the GOLD self signed certificate, defaults to "". Using the default value is *not* recommended.
* **organisation**:  The organisation name for the GOLD self signed certificate, defaults to "". Using the default value is *not* recommended.
* **ou**: The organisational unit for the GOLD self signed certificate, defaults to "". 
* **admin_email**: An email address for the GOLD administrator, this value is required and there is no default.
* **extra_groups**: A list of extra user groups to add to the gold user, defaults to 'false' indicating no additional groups are required.

# To do...

# Credits

Written by Aaron Hicks (hicksa@landcareresearch.co.nz) for the New Zealand eScience Infrastructure.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/"><img alt="Creative Commons Licence" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/">Creative Commons Attribution-ShareAlike 3.0 Unported License</a>