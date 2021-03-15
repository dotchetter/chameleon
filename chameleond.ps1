
<#
    Chameleon - An automated bright / dark mode toggle
    service that follows the sun.

    Author:
        Simon Olofsson
        dotchetter@protonmail.ch
        https://github.com/dotchetter

    Date:
        2021-03-07

    Backend logic file, invoked as daemon by chameleond

#>
Import-Module .\helpers.ps1

$location = getLocationFromWindows10LocationApi
$sundata = getSunSetSunRiseDataFromPublicApi $location
$previousCheck = Get-Date
$sundataUpdatedTimestamp = Get-Date
$previousValue = -1
$colorValue = -1

while (1)
{
    if (((Get-Date) - $sundataUpdatedTimestamp).days)
    {
        $location = getLocationFromWindows10LocationApi
        $sundata = getSunSetSunRiseDataFromPublicApi $location
    }

    $colorValue = evaluateBrightOrDarkmode $sundata

    if ($previousValue -ne $colorValue)
    {
        setRegistryValues $colorValue
        $previousValue = $colorValue
    }

    Start-Sleep -Seconds ($INTERVAL_MINUTES * 60)
}