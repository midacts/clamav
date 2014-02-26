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
# John McCarthy <midactsmystery@gmail.com>
#
#
class clamav::clamscan {

  # This enables are the variables from the params class to be used here
  require clamav::params

  # Installs SSMTP to send virus detection emails
  package { 'ssmtp':
    ensure	=> present,
  }

  # Sets up the default ssmtp configuration file
  file { '/etc/ssmtp/ssmtp.conf':
    ensure	=> file,
    content	=> template('clamav/ssmtp.conf.erb'),
    mode	=> '644',
    owner	=> 'root',
    group	=> 'root',
    require	=> Package['ssmtp'],
  }

  # This creates and handles the permissions for the clamav.log file
  # used for clamscan
  file { "${clamav::params::clamscan_log}":
    ensure      => present,
    mode        => '644',
    owner       => "${clamav::params::user}",
    group       => "${clamav::params::group}",
    require     => Cron ['clamscan'],
  }

  # Creates the shell script for the cron job to execute
  file { '/var/log/clamav/clamscan.sh':
    ensure	=> file,
    content	=> template('clamav/clamscan.sh.erb'),
    mode	=> '777',
    owner       => "${clamav::params::user}",
    group       => "${clamav::params::group}",
    require	=> Package['ssmtp'],
    notify	=> Cron['clamscan'],
  }

  # Creates the clamscan job on all node
  cron { 'clamscan':
    ensure      => present,
    command     => '/var/log/clamav/clamscan.sh',
    user        => "${clamav::params::user}",
    hour        => "${clamav::params::hour}",
    minute      => "${clamav::params::minute}",
    require     => Package ["${clamav::params::clamav_package}"],
  }
}
