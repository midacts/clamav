# Class
# ------
# clamav::params
#
# Synopsis
# ---------
# This files is used to define all variables that are used 
# in all classes and manifests.
#
# Example
# --------
# class test {
#   
#   require clamav::params
#   
#   file { "${clamav::params::$daily_origin}":
#     ensure	=> present
#   }
# }
#
# Author
# --------
# John McCarthy <jmccarthy@orthobanc.com>
#
#
class clamav::params {
  
  # Database file variables
  $daily_file		= '/etc/puppetlabs/puppet/modules/clamav/files/daily.cvd'
  $main_file		= '/etc/puppetlabs/puppet/modules/clamav/files/main.cvd'

  # ssmtp.conf Variable for mailhub 
  $mailserver		= '172.16.3.30'

  # clamscan.sh.erb EMAIL variable 
  $email		= 'jmccarthy@orthobanc.com'

  # Date used for the clamscan.log variable
  $date                 = inline_template("<%= Time.now.strftime('%m%d%Y') %>")

  # Clamscan.log location and name variable
  $clamscan_log         = "/var/log/clamav/${date}_clamav.log"

  # hour variable used for clamscan cron job
  $hour			= '4'

  # minute variable usef for clamscan cron job
  $minute		= '0'

  # Case to hand out variables based on the operating system
  case $::operatingsystem {
    centos, opensuse:   {
      $clamav_package	= 'clamd'
      $clamd_file       = '/etc/clamd.conf'
      $databasedir      = '/var/clamav'
      $daily_origin	= '/var/clamav/daily.cvd'
      $main_origin	= '/var/clamav/main.cvd'
      $freshclam_file 	= '/etc/freshclam.conf'
      $freshclam_srv	= 'clamav-freshclam'
      $user		= 'clam'
      $group		= 'clam'
      file { '/etc/cron.daily/freshclam':
        ensure		=> absent,
      }
    }
    debian, ubuntu:     {
      $clamav_package	= 'clamav'
      $clamd_file       = '/etc/clamav/clamd.conf'
      $databasedir	= '/var/lib/clamav'
      $daily_origin     = '/var/lib/clamav/daily.cvd'
      $main_origin      = '/var/lib/clamav/main.cvd'
      $freshclam_file 	= '/etc/clamav/freshclam.conf'
      $freshclam_srv	= 'clamav-freshclam'
      $user		= 'clamav'
      $group		= 'clamav'
    }
  }
}
