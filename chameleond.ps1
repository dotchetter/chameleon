
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
   
    Backend logic file, invoked as daemon by chameleond

#>
Import-Module .\helpers.ps1
Import-Module .\Settings.ps1

$location = getLocationFromWindows10LocationApi
$sundata = getSunSetSunRiseDataFromPublicApi $location
$previousCheck = Get-Date
$sundataUpdatedTimestamp = Get-Date
$settings = [Settings]::new()

while (1)
{
    if (((Get-Date) - $sundataUpdatedTimestamp).days)
    {
        $location = getLocationFromWindows10LocationApi
        $sundata = getSunSetSunRiseDataFromPublicApi $location
    }

    $sunTheme = evaluateBrightOrDarkmode $sundata
    Write-Output $sunTheme
    
    if (($previousTheme -ne $sunTheme))
    {
        $settings = [Settings]::load()
        if ($settings.sunEnabled())
        {
            $settings.setTheme($sunTheme)
            $previousTheme = $sunTheme
        }
    }

    Start-Sleep -Seconds ($INTERVAL_MINUTES * 60)
}