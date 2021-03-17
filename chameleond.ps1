
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

$location = getLocationFromWindows10LocationApi
$sundata = getSunSetSunRiseDataFromPublicApi $location
$previousCheck = Get-Date
$sundataUpdatedTimestamp = Get-Date

while (1)
{
    if (((Get-Date) - $sundataUpdatedTimestamp).days)
    {
        $location = getLocationFromWindows10LocationApi
        $sundata = getSunSetSunRiseDataFromPublicApi $location
    }

    $script:sunTheme = evaluateBrightOrDarkmode $sundata

    if ($previousTheme -ne $script:sunTheme)
    {
        [Themes]::sun | setTheme
        $previousTheme = $script:sunTheme
    }

    Start-Sleep -Seconds ($INTERVAL_MINUTES * 60)
}