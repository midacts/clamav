# Class
# ------
# clamav::freshclam
#
# Synopsis
# ---------
# This is for configuring freshclam, the piece of ClamAV
# that keeps the virus definitions up to date. Freshclam
# is maintained and updated by the Puppet Master.
#
# Author
# -------
# John McCarthy <midactsmystery@gmail.com>
#
#
class clamav::freshclam inherits clamav {

  # This enables are the variables from the params class to be used here
  require clamav::params

  # Copies the newest daily.cvd file from the Puppet Master's database
  # directory, and copies it to 'puppet:///modules/clamav/daily.cvd'. From
  # there, all the nodes can pull the latest Clamav database files without
  # having to run freshclam locally on each machine.
  file { "${clamav::params::daily_file}":
    ensure	=> file,
    source	=> "${clamav::params::daily_origin}",
    backup	=> false,
    require	=> Service ["${clamav::params::freshclam_srv}"],
  }

  # Copies the newest main.cvd file from the Puppet Master's database
  # directory, and copies it to 'puppet:///modules/clamav/main.cvd'. From
  # there, all the nodes can pull the latest Clamav database files without
  # having to run freshclam locally on each machine.
  file { "${clamav::params::main_file}":
    ensure	=> file,
    source	=> "${clamav::params::main_origin}",
    backup	=> false,
    require     => Service ["${clamav::params::freshclam_srv}"],
  }

  # Enables the Freshclam service for the Puppet Master ONLY. capitalizing
  # the 'S' in Service references the Freshclam service in init.pp and allows 
  # us to change the Freshclam service on only the Puppet Master.
  Service ["${clamav::params::freshclam_srv}"] {
    ensure      => true,
    enable      => true,
  }
}
