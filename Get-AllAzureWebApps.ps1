<#
.SYNOPSIS
    Queries Azure to get a list all web apps in all subscriptions.

.DESCRIPTION
    This script doesn't require any parameters. It checks to see if the powershell isntance is 
    already logged into Azure and prompts the user to log in if not. It then loops through all
    subscription, gets the web apps associated with each and dumps the output to a CSV file.

.PARAMETER
    None
    
.EXAMPLE
    Get-AllAzureWebApps


#>

function Check-Session () {
    $Error.Clear()

    #if context already exist
    Get-AzureRmContext -ErrorAction Continue
    foreach ($eacherror in $Error) {
        if ($eacherror.Exception.ToString() -like "*Run Login-AzureRmAccount to login.*") {
            Login-AzureRmAccount
        }
    }

    $Error.Clear();
}

$applications = @()

Check-Session

$subscriptions = Get-AzureRmSubscription
foreach($subscription in $subscriptions){
    $subscription | Select-AzureRmSubscription
    $apps = Get-AzureRmWebApp
    foreach($app in $apps){
        $app | Add-Member -NotePropertyName Subscription -NotePropertyValue $subscription.SubscriptionName
        $applications += $app
    }

}

$applications | Select SiteName, State, Location, @{Name='HostNames';Expression={[string]::join(", ",($_.HostNames))}}, ServerFarmId |Export-CSV -NoTypeInformation .\WebApps.csv


