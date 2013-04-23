# Class
# ------
# clamav::database
#
# Synopsis
# ---------
# This class is used to get the latest database files from the 
# Puppet Master. The Puppet Master is the only server running 
# 'freshclam'. As the Puppet Master gets the latest database
# files, it upload them to 'puppet:///modules/clamav/files',
# which is where all the nodes will pull the latest database 
# files from.
#
# Author
# --------
# John McCarthy <jmccarthy@orthobanc.com>
#
#
class clamav::database {

  # This enables are the variables from the params class to be used here
  require clamav::params

  # Copies the main.cvd files to the node's local clamav database directory
  file { 'main_cvd':
    ensure    	=> file,
    path      	=> "${clamav::params::main_origin}",
    source    	=> 'puppet:///modules/clamav/main.cvd',
    backup	=> false,
    mode      	=> 644,
    owner     	=> "${clamav::params::user}",
    group     	=> "${clamav::params::group}",
    require   	=> Package["${clamav::params::clamav_package}"],
  }

  # Copies the daily.cvd files to the node's local clamav database directory
  file { 'daily_cvd':
    ensure    	=> file,
    path      	=> "${clamav::params::daily_origin}",
    source    	=> 'puppet:///modules/clamav/daily.cvd',
    backup	=> false,
    mode      	=> 644,
    owner       => "${clamav::params::user}",
    group       => "${clamav::params::group}",
    require   	=> Package["${clamav::params::clamav_package}"],
  }
}
