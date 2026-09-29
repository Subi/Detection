<#
 Grabbed the SID from the profilelist because this includes offline profiles as well. Loop through each SID and check if active user by ""Registry::HKEY_USERS/{SID}""
 you can then remdiate if you detect program, if the checking for {SID} through HKEY_USERS failes , means profile is not active and Hive needs to be loaded then remediated
#>

param (
    [string]$ENV,
    [string]$App
)


$profileListPath =  "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
$profiles = Get-ChildItem -Path $profileListPath | Get-ItemProperty | Where-Object {$null -ne $_.FullProfile} | Select-Object PSChildName

function Development {
$profiles | ForEach-Object {
    if(Test-Path "Registry::HKEY_USERS\$($_.PSChildName)") {
        Write-Output "Profile found... $($_.PSChildName)"
        Write-Output "Looking for $($App)..."
        if(Test-Path "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall\$($App)") {
            Write-Output "Found $($App)"
        } else {
            Write-Host "$($App) was not found"
        }
    }
 }
}


function Production {
    $profiles | ForEach-Object {
    if(Test-Path "Registry::HKEY_USERS\$($_.PSChildName)" -ErrorAction SilentlyContinue ) {
        if(Test-Path "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall\$($App)" -ErrorAction SilentlyContinue) {
            Ninja-Property-Set "genericUseText" 1
        } else {
            Ninja-Property-Set "genericUseText" 0
        }
    }
 }
}

function Initialize-Script {
    if([string]::IsNullOrEmpty($ENV)){
        Production
    } else {
        Development
    }
}


Initialize-Script

