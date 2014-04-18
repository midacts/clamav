CLAMAV
======

Puppet module to implement and maintain clamav on Linux servers. This module has been tested on:
    
    Debian 6 and 7
    Ubuntu 12.04
    CentOS 5 and 6
    
MANIFEST FILES
--------------

##`init.pp`
This file contains the clamav class. It then creates and installs the following packages and files:
    
* **clamav package**
* **clamd.conf files**
* **freshclam.conf file**

It then proceeds to turns the freshclam service off. The Puppet Master is the only server that runs freshclam so that it 
is the only server that has to search and download the latest database files. All Puppet Agents pull the latest database
files from the Puppet Master via "puppet:///modules/clamav".

This code finishes by calling the remaining classes. The Puppet Master as well as all the Puppet Agents call the
'clamscan' class, because this is what schedules each server to run clamscan daily. The Puppet Master is the only server
that calls the freshclam class. This is because the Puppet Master is the only server that runs 'freshclam' and downloads
the latest database files. THis way, only one server has to do updates and cuts down on bandwidth and space. The Puppet
Master then moves the latest database files to the "puppet:///modules/clamav" directory where each Puppet Agent can pull
the latest database files to its database directory.

The Puppet Agents are the only servers that run the 'database' class. This class enables the Puppet Agents to pull the 
latest database files from the "puppet:///modules/clamav" directory and copy them to their database directory.
    
    Puppet Master: 
      freshclam
      clamscan

    Puppet Agent:
      database
      clamscan
        

##`params.pp`
This file is used to store all the variables for all the other classes.

##`freshclam.pp`
This file is used to enable the 'freshclam' service for the Puppet Master. It then runs freshclam hourly to search for
the latest database files. If new database files are found, they are downloaded to the Puppet Master's database directory
and are then copied to the "puppet:///modules/clamav" directory."

##`database.pp`
This file is used by every Puppet Agent to copy the latest database files from the Puppet Master at 
"puppet:///modules/clamav" into its own local database directory. Thus giving each Puppet Agent the latest database files
without having to run 'freshclam' and take up memory to run the process and bandwidth to download the latest database 
files.

##`clamscan.pp`
This file is used by both the Puppet Master and Puppet Agent to enable 'clamscan' to be set up as a daily cron job. It 
starts by installing:

* **SSMTP** 

This package is need in order for the clamscan script to send email reports if a virus has been detected. It then pushes
out a 

* **ssmtp.conf** template file that is managed by the Puppet Master.

Once SSMTP is set up, if creates the 

* **daily log file**


This log file is named after the currecnt day following the MMddyyyy pattern (ex. 05312013) followed by '_clamav.log. So
each log file will follow this pattern:  '05312013_clamav.log'.

Once the log file is created, It pushes a temporary clamscan.sh shell script to the '/var/log/clamav' directory which the
clamscan cron job will use as its commands when it runs daily.



TEMPLATES
---------

There are four template files included with this modules:

* **clamd.conf.erb**
* **freshclam.conf.erb**
* **ssmtp.conf.erb**
* **clamscan.sh.erb**

These files are used to make the config files and startup scripts that are pushed to each of the Puppet Agent and Puppet
Master servers.

##`clamd.conf.erb`
This template sets the default clamd.conf file answers on every server. It specifically generates te following parameters

* **DatabaseDirectory**
* **LocalSocketGroup**
* **LogFile**
* **User**

##`freshclam.conf.erb`
This template sets the default freshclam.conf file answers on every server. It specifically generates te following 
parameters

* **DatabaseDirectory**
* **DatabaseOwner**

##`ssmtp.conf.erb`
This template sets the default ssmtp.conf file answers on every server. It specifically generates te following 
parameters

* **mailhub=<%= clamav::params::mailserver %>** 
* **hostname=<%= fqdn %>** to automatically generate a the unique server hostname for every server's ssmtp.conf

##`clamscan.sh.erb`
This file was found on 'Devon Hillard's Digital Sanctuary' which can be found at 
<http://www.digitalsanctuary.com/tech-blog/debian/automated-clamav-virus-scanning.html>

I used his code that he made to be used for daily clamscan runs. This script runs clamscan and searches the log file for
infected files. It then will email the supplied email addresses of any found infected files. I made this file template
so that i could auto generate the 'fqdn' for the SUBJECT variable. I also used my 'clamscan_log' variable for the LOG 
variable. The EMAIL variable is set by the clamav::params::email variable. Lastly, I changed 'clamscan' to scan '-r /'.





# NOTE #
1. Open Source Puppet users need only to alter the 'Database files' found in the 'clamav:params' file.
2. If your Puppet Master's hostname is something other than 'puppet' please change line 55 of clamav/manifests/init.pp
   from 'puppet' to the hostname of your server. I have not had alot of luck with facter always having the 
   'fact_is_puppetmaster' fact.
