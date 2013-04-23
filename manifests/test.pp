class clamav::test {

  cron { 'clamscan':
    ensure	=> present,
    command	=> template('/clamav/clamscan.erb'),
    user	=> "${clamav::params::user}",
    hour	=> "${clamav::params::hour}",
    minute	=> "${clamav::params::minute}",
  }
}
