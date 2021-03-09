
<#
    Chameleon - An automated bright / dark mode toggle
    service that follows the sun.


    Author:
        Simon Olofsson
        dotchetter@protonmail.ch
        https://github.com/dotchetter

    Date:
        2021-03-07

#>

Add-Type -AssemblyName System.Device

$INTERVAL_MINUTES = 1

function getLocationFromWindows10LocationApi()
<# 
    Returns a hashtable object containing
    coordinates obtained from the internal
    Windows 10 API, if enabled.
#>
{    
    Write-Host "[Chameleon] Verifying location data access: " -NoNewLine -ForeGroundColor Yellow
    
    $GeoWatcher = New-Object System.Device.Location.GeoCoordinateWatcher
    $GeoWatcher.Start()

    while (($GeoWatcher.Status -ne 'Ready') -and ($GeoWatcher.Permission -ne 'Denied')) 
    {
        Start-Sleep -Milliseconds 100 
    }
    
    Write-Host "done." -ForeGroundColor Green
    
    while ($GeoWatcher.Permission -ne 'Granted')
    {
        Write-Warning  ("Chameleon requires Positioning to be turned
                        `ron to work propertly. Do you want to open
                        `rsettings and turn this feature on?") 

        $openSettings = Read-Host "Y/N"

        if ($openSettings.ToLower() -eq "y")
        {
            Write-Host "[Chameleon] Settings will open. Hit Enter when you're done"
            Start-Process ms-settings:privacy-location
            Read-Host "Waiting.."
        }
        else
        {
            Write-Host "bye." -ForeGroundColor Green
            exit       
        }
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
    Write-Host "[Chameleon] Obtaining sunrise and sunset data from API: " -NoNewLine -ForeGroundColor Yellow
    $long = $locationData.Longitude
    $lat = $locationData.Latitude

    $request = "https://api.sunrise-sunset.org/json?lat=$lat&lng=$long"
    
    try
    {
        $err = $null
        $response = Invoke-WebRequest $request -ErrorVariable err
    }
    catch [Exception]
    {
        Write-Warning "[Chameleon] Chameleon could not connect to the server.`nErrormessage: $err"
        exit
    }        

    $timeinfo = $response.Content | ConvertFrom-Json | Select-Object results
    
    Write-Host "done." -ForeGroundColor Green
    return $timeInfo
}


function evaluateBrightOrDarkmode($sundata)
{
    $now = Get-Date

    if ($now -gt $sundata.sunset)
    {
        return "dark"
    }
    return "light"
}


function setRegistryValues($value)
{
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $value -Type Dword -Force | Out-Null  
    New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $value -Type Dword -Force | Out-Null 
}


function main()
{
    $location = getLocationFromWindows10LocationApi
    $sundata = getSunSetSunRiseDataFromPublicApi $location
    $previousCheck = Get-Date
    $sundataUpdatedTimestamp = Get-Date
    $currentLightTheme = -1
    $colorValue
    
    while (1)
    {
        if (($sundataUpdatedTimestamp - (Get-Date)).Days -ge 1)
        {
            $location = getLocationFromWindows10LocationApi
            $sundata = getSunSetSunRiseDataFromPublicApi $location
        }


        if ($currentLightTheme -ne $colorValue)
        {
            switch (evaluateBrightOrDarkmode)
            {
                "dark"
                {
                    Write-Host "[Chameleon] It's past sunset - setting dark mode" -ForeGroundColor Yellow
                    $colorValue = 0
                }
                "light"
                {
                    Write-Host "[Chameleon] The sun is up - setting bright mode" -ForeGroundColor Yellow
                    $colorValue = 1
                }
            }
            setRegistryValues $colorValue
            $currentLightTheme = $colorValue
        }

        Start-Sleep -Seconds ($INTERVAL_MINUTES * 60)
    }    
}

Write-Host ("`nChameleon - Open source light / dark theme
            `rtoggle service for Windows 10 by Simon Olofsson
            `rhttps://github.com/dotchetter
            `r`n*******************************************
            `rChameleon is starting and will automatically switch
            `rfrom light to dark theme according to the sunset and
            `rsunrise at your location. 
            `rThe interval is set to $INTERVAL_MINUTES minute(s).
            `r`n`n")

main