<# 
.SYNOPSIS 
Adds IP Restrictions for IIS websites

.DESCRIPTION 
Begins by shutting down the site, then adds IP address allow / deny rules and then starts the site back up.
#> 


Import-Module WebAdministration

Stop-Website 'SiteName'

#Adds an allow exception#
Add-WebConfiguration -Filter /system.webserver/security/ipsecurity -Value @{ipAddress="X.X.X.X";subnetMask="X.X.X.X";allowed="true"} -Location "SiteName" -PSPath "IIS:\"
#Denies everything else#
Add-WebConfiguration -Filter /system.webserver/security/ipsecurity -Value @{ipAddress="0.0.0.0";subnetmask="255.255.255.255";allowed="false"} -Location "SiteName" -PSPath "IIS:\"

Start-Website 'SiteName'
