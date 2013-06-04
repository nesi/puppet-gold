# NeSI G.O.L.D. deployment module
# Deploy the GOLD accounting system by Adaptive Computing
# http://www.adaptivecomputing.com/products/open-source/gold/
#
# Installed as per the GOLD User Guide:
# http://www.adaptivecomputing.com/resources/docs/gold/index.php

class gold(
  $version      = '2.2.0.5',
  $web_ui       = false,
  $pass_phrase  = 'changeme',
  $psql_server  = false,
  $db_user      = 'gold',
  $db_name      = 'gold',
  $country      = "",
  $state        = "",
  $city         = "",
  $organisation = "",
  $ou           = "",
  $admin_email,
  $extra_groups = false
){
  case $operatingsystem {

    Ubuntu: {
      class{'gold::install':
        version       => $version,
        web_ui        => $web_ui,
        pass_phrase   => $pass_phrase,
        psql_server   => $psql_server,
        db_user       => $db_user,
        db_name       => $db_name,
        country       => $country,
        state         => $state,
        city          => $city,
        organisation  => $organisation,
        ou            => $ou,
        admin_email   => $admin_email,
        extra_groups  => $extra_groups,
      }
    }
    default: {
      warning{"GOLD is not configured for $operatingsystem":}
    }
  }


}