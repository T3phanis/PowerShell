<# 
.SYNOPSIS 
Gathers freespace from remote hosts. 

.DESCRIPTION 
Will prompt for either a hostname or a path to a list of servers you would like information for.

.Requirements
Nothing specific.
#> 

Function Show-Menu {

Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter your menu text")]
[ValidateNotNullOrEmpty()]
[string]$Menu,
[Parameter(Position=1)]
[ValidateNotNullOrEmpty()]
[string]$Title="Menu",
[switch]$ClearScreen
)

if ($ClearScreen) {Clear-Host}

#build the menu prompt
$menuPrompt=$title
#add a return
$menuprompt+="`n"
#add an underline
$menuprompt+="-"*$title.Length
$menuprompt+="`n"
#add the menu
$menuPrompt+=$menu

Read-Host -Prompt $menuprompt

} #end function


$diskmenu=@"
1 Enter remote server
2 Enter path to server list
Q quit
"@

switch (show-menu $diskmenu "Please choose an option") {
"1" {Get-WmiObject Win32_Logicaldisk -Filter "DriveType=3" -ComputerName (Read-Host "Enter server name ") | Select SystemName,DeviceID,VolumeName,@{Name="Size(GB)";Expression={"{0:N1}" -f($_.size/1gb)}},@{Name="FreeSpace(GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}};}
"2" {$list = read-host "Path to server list: "
    Get-Content $list | % { Get-WmiObject win32_logicaldisk -Filter "DriveType=3" -ComputerName $_ | Select systemname,deviceID,VolumeName,@{Name="Size(GB)";Expression={"{0:N1}" -f ($_.size/1gb)}},@{Name="FreeSpace(GB)";Expression={"{0:N1}" -f($_.freespace/1gb)}};} | Out-GridView;}
}