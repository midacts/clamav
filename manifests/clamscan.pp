# Class
# ------
# clamav::clamscan
#
# Synopsis
# ---------
# This class is used to create the 'clamscan' cron job as well as making sure
# a log file is present and logged to daily.
#
# Author
# --------
# John McCarthy <jmccarthy@orthobanc.com>
#
#
class clamav::clamscan {

  # This enables are the variables from the params class to be used here
  require clamav::params

  # This creates and handles the permissions for the clamav.log file
  # used for clamscan
  file { "${clamav::params::clamscan_log}":
    ensure      => present,
    mode        => "644",
    owner       => "clamav",
    group       => "clamav",
    require     => Cron ['clamscan'],
  }

  # Creates the clamscan job on all node
  cron { 'clamscan':
    ensure      => present,
    command     => "/usr/bin/clamscan -r / -l '${clamav::params::clamscan_log}'",
    user        => clamav,
    hour        => "${clamav::params::hour}",
    minute      => "${clamav::params::minute}",
    require     => Package ["${clamav::params::clamav_package}"],
  }
}
