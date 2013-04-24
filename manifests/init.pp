# Class
# ------
# clamav
#
# Synopsis
# ---------
# This is the main class for configuring Clamav. Freshclam 
# is maintained and updated by the Puppet Master. This file 
# will install the latest version of Clamav, and copy the 
# custom clamd.conf and freshclam.conf files to each node.
#
# Author
# --------
# John McCarthy <jmccarthy@orthobanc.com>
#
#
class clamav {

  # This enables are the variables from the params class to be used here
  require clamav::params

  # Installs the latest version of Clamav
  package { "${clamav::params::clamav_package}":
    ensure      => latest,
  }

  # Copies the clamd.conf file to each node
  file { "${clamav::params::clamd_file}":
    ensure      => present,
    content     => template('clamav/clamd.conf.erb'),
    mode        => '644',
    owner       => "${clamav::params::user}",
    group       => "${clamav::params::group}",
    require     => Package["${clamav::params::clamav_package}"],
  }

  # Copies the freshclam.conf file to each noe
  file { "${clamav::params::freshclam_file}":
    ensure      => present,
    content     => template('clamav/freshclam.conf.erb'),
    owner       => "${clamav::params::user}",
    group       => "${clamav::params::group}",
    require     => Package["${clamav::params::clamav_package}"],
  }

  # This controls the freshclam service. It is disabled by deafault
  # because freshclam is managed and maintained by the Puppet Master
  service { "${clamav::params::freshclam_srv}":
    ensure      => false,
    enable      => false, 
    subscribe	=> File["${clamav::params::clamd_file}"]
  }

  # Calls the corresponding classes whether it is the Puppet Master or Agent
  if $fact_is_puppetmaster == 'true' {
    include clamav::freshclam
    include clamav::clamscan
  }
  else {
    include clamav::database
    include clamav::clamscan
  }
}

