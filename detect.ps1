
# Set Command-Line Variables
param (
    [string]$ENV,
    [string]$App
)
# Assign registry path for user profiles on machine
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
        if(Test-Path "Registry::HKEY_USERS\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall\Wispr Flow" -ErrorAction SilentlyContinue) {
            Ninja-Property-Set "genericUseText" 1
        } else {
            Ninja-Property-Set "genericUseText" 0
        }
    }
 }
}

#Initition script, passed in enviroment variables controls scripts flow.
function Initialize-Script {
    if([string]::IsNullOrEmpty($ENV)){
        Production
    } else {
        Development
    }
}


Initialize-Script

