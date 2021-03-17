
<#
    Chameleon - An automated bright / dark mode toggle
    service that follows the sun.

    Authors:
        Simon Olofsson
        dotchetter@protonmail.ch
        https://github.com/dotchetter

        Michael Hällström
        https://github.com/yousernaym

    Date:
        2021-03-17
   
    Functions used for core functionalities in Chameleon

#>

$INTERVAL_MINUTES = 1
enum Themes { light; dark; sun }
Add-Type -AssemblyName System.Device

function getLocationFromWindows10LocationApi()
<# 
    Returns a hashtable object containing
    coordinates obtained from the internal
    Windows 10 API, if enabled.
#>
{        
    $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
    $GeoWatcher.Start()

    while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) 
    {
        Start-Sleep -Milliseconds 100 
    }
    
    if ($GeoWatcher.Permission -ne 'Granted')
    {
        Start-Process ms-settings:privacy-location

        $msg = "Oops! Chameleon uses your position for accurate sun hour data. " +
               "We noticed that this is disabled on your system.`n`n" +
               "Please turn on this feature if you want to use Chameleon.`n`n" + 
               "As you can see, I opened the settings pane for you. " +
               "Turn on 'Allow apps to access your location' and hit OK when you're done, " +
               "then start Chameleon again. Sound good?"

        [Windows.Forms.MessageBox]::show("$msg", "Chameleon - Windows 10 Location API disabled",
        [Windows.Forms.MessageBoxButtons]::Ok, [Windows.Forms.MessageBoxIcon]::"Information") | Out-Null

        Stop-Process $pid        
    } 
    return $GeoWatcher.Position.Location | Select-Object Latitude, Longitude
}


function getSunSetSunRiseDataFromPublicApi($locationData)
<#
    Obtains JSON structured data from external
    api based upon received location in 
    latitude and longitude. 
#>
{
    $long = $locationData.Longitude
    $lat = $locationData.Latitude

    $request = "https://api.sunrise-sunset.org/json?lat=$lat&lng=$long"
    
    try
    {
        $err = $null
        $response = Invoke-WebRequest $request -ErrorVariable err
        $results = $response | ConvertFrom-Json | Select-Object results -ExpandProperty results
    }
    catch [Exception]
    {
        Write-Host "Chameleon could not connect to the server.`nErrormessage: $err"
        exit
    }        
    return $results
}


function evaluateBrightOrDarkmode($sundata)
<#
    Evealuates whether the current time of 
    call is during sun up or sun down, and
    returns 'dark' or 'light' depending on 
    the outcome.
#>
{
    $now = Get-Date

    switch ($now -gt  [Datetime]::Parse($sundata.sunrise) -and $now -lt [Datetime]::Parse($sundata.sunset))
    {
        $true { return [Themes]::light }
        $false { return [Themes]::dark}
    }
}

function setTheme()
{
    param (
    [parameter(ValueFromPipeline)]
    [Themes]
    $theme
    )
    if ($null -eq $theme) {
        return
    }
    if (($theme -ne [Themes]::sun) -or $sunEnabled)
    {
        if ($theme -eq [Themes]::sun) {
            $effectiveTheme =  $script:sunTheme
        }
        else {
            $effectiveTheme = $theme
        }
        if ($effectiveTheme -eq [Themes]::light) {
            $regValue = 1
        }
        else {
            $regValue = 0
        }
        if ($systemEnabled) {
            New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $regValue -Type Dword -Force | Out-Null  
        }
        if ($appsEnabled) {
            New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $regValue -Type Dword -Force | Out-Null 
        }
    }
}