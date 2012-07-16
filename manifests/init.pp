# NeSI G.O.L.D. deployment module
# Deploy the GOLD accounting system by Adaptive Computing
# http://www.adaptivecomputing.com/products/open-source/gold/
#
# Installed as per the GOLD User Guide:
# http://www.adaptivecomputing.com/resources/docs/gold/index.php

class gold(
  $version  = '2.2.0.4',
  $web_ui   = false,
  $httpd    = 'apache2'
){
  case $operatingsystem {
    Ubuntu: {
      class{'gold::install':
        version => $version,
        web_ui  => $web_ui,
      }
    }
    default: {
      warning{"GOLD is not configured for $operatingsystem":}
    }
  }


}