<# 
.SYNOPSIS 
Gathers user information from active directory. 

.DESCRIPTION 
Utilizes Get-ADUser to gather AD User information then the script creates multiple output files containing:
    All users 
    Users with expired passwords
    Inactive user accounts
    Disabled user accounts
    Accounts that contain default administravive groups

Output files will be stored in the directory the script has been executed from.

.Requirements
This script will require powershell version 3 or higher. This script will make use of the active directory modules within powershell.
For these to be available Windows Remote Administration Toolset will need to be installed, or active directory itself will need installed. 

#> 

#Load Active Directory Module if not using PowerShell V3
Import-Module ActiveDirectory

#Setting variables for use within the script#
$date = get-date
$users = get-aduser -filter * -Properties AllowReversiblePasswordEncryption, CannotChangePassword, Description, Enabled, LastLogonDate, Name, PasswordExpired, PasswordLastSet, PasswordNeverExpires, TrustedForDelegation
$groups = Get-ADGroup -filter *

#Function for building the menu that will be used within the loop later#
Function Show-Menu {

Param(
[Parameter(Position=0,Mandatory=$True,HelpMessage="Enter your menu text")]
[ValidateNotNullOrEmpty()]
[string]$Menu,
[Parameter(Position=1)]
[ValidateNotNullOrEmpty()]
[string]$Title="Active Directory User Collector",
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

#Defining menu that will be displayed to user
$menu=@"
1 Gather All Users Within Active Directory
2 Gather All Inactive Users (No Activity For 2 weeks)
3 Gather All Disabled User Accounts
4 Gather All Users With Reversible Encryption Enabled
5 Gather Password Properties
6 Gather All Domain Security Groups
7 Accounts Trusted For Delegation
8 Execute All
Q Quit

Select a task by number or Q to quit
"@

#Keep looping and running the menu until the user selects Q (or q).
Do {
    #use a Switch construct to take action depending on what menu choice
    #is selected.
    Switch (Show-Menu $menu "Active Directory User Collector" -clear) {
    
    #Gathers all user accounts in the domain#
    "1" { $users | Select-Object name, samaccountname,Description, enabled | Sort-Object enabled, name | Format-Table -AutoSize | Out-File $PSScriptRoot\AllUsers.txt} 

    #Gather user accounts that have not been active for two weeks#
    "2" { $users | Select-Object Name, LastLogonDate, Enabled | Where-Object {$_.LastLogonDate -le $date.AddDays(-14)} | Sort-Object LastLogonDate | Format-Table -AutoSize | Out-File $PSScriptRoot\InactiveUsers.txt}
	
    #Gathers all disabled user accounts#
    "3" {$users | Select-Object Name, LastLogonDate, Enabled | Where-Object {$_.false -eq $True} | Sort-Object LastLogonDate | Format-Table -AutoSize | Out-File $PSScriptRoot\DisabledUsers.txt}
	
    #Gathers all users with Reversible Encryption Enabled#
    "4" {$users | Select-Object Name, Enabled, AllowReversiblePasswordEncryption | Where-Object {$_.AllowReversiblePasswordEncryption -eq $True} | Sort-Object name | Format-Table -AutoSize | Out-File $PSScriptRoot\AllowReversiblePasswordEncryption.txt}

    #Gathers Password properties (Password expired, Password last set date, Passwords that never expire, Accounts that are not able to change passwords#
    "5" {$users | Select-Object Name, PasswordExpired, PasswordLastSet, PasswordNeverExpires, CannotChangePassword | Sort-Object name | Format-Table -AutoSize | Out-File $PSScriptRoot\PasswordProperties.txt}

    #Gathers all security groups within the domain#
    "6" {$groups | Select-Object Name, GroupCategory | ? {$_.groupcategory -eq "Security"} | sort-object name | Format-Table -AutoSize | Out-File $PSScriptRoot\SecurityGroups.txt}

    #Accounts trusted for delegation
    "7" {$users | Select-Object name, samaccountname, enabled, Trustedfordelegation | ? {$_.TrustedForDelegation -eq $True} | Sort-Object enabled, name | Format-Table -AutoSize | Out-File $PSScriptRoot\UserswithDelegation.txt} 
    
    #Dumps all at once#   
    "8" {$users | Select-Object name, samaccountname,Description, enabled | Sort-Object enabled, name | Format-Table -AutoSize | Out-File $PSScriptRoot\AllUsers.txt;
         $users | Select-Object Name, LastLogonDate, Enabled | Where-Object {$_.LastLogonDate -le $date.AddDays(-14)} | Sort-Object LastLogonDate | Format-Table -AutoSize | Out-File $PSScriptRoot\InactiveUsers.txt;
         $users | Select-Object Name, LastLogonDate, Enabled | Where-Object {$_.false -eq $True} | Sort-Object LastLogonDate | Format-Table -AutoSize | Out-File $PSScriptRoot\DisabledUsers.txt;
         $users | Select-Object Name, Enabled, AllowReversiblePasswordEncryption | Where-Object {$_.AllowReversiblePasswordEncryption -eq $True} | Sort-Object name | Format-Table -AutoSize | Out-File $PSScriptRoot\AllowReversiblePasswordEncryption.txt;
         $users | Select-Object Name, PasswordExpired, PasswordLastSet, PasswordNeverExpires, CannotChangePassword | Sort-Object name | Format-Table -AutoSize | Out-File $PSScriptRoot\PasswordProperties.txt;
         $groups | Select-Object Name, GroupCategory | ? {$_.groupcategory -eq "Security"} | sort-object name | Format-Table -AutoSize | Out-File $PSScriptRoot\SecurityGroups.txt;
         $users | Select-Object name, samaccountname, enabled, Trustedfordelegation | ? {$_.TrustedForDelegation -eq $True} | Sort-Object enabled, name | Format-Table -AutoSize | Out-File $PSScriptRoot\UserswithDelegation.txt;
        }    

    "Q" {Write-Host "Goodbye" -ForegroundColor Green
         Return
         }
     Default {Write-Warning "Invalid Choice. Try again."
              sleep -milliseconds 750}
    } #switch
} While ($True) 