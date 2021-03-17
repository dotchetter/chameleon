Import-Module .\helpers.ps1
Add-Type -AssemblyName PresentationFramework

#Create window
[xml]$xaml = Get-Content ".\settings.xaml"
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

#useDarkRb click event
$useDarkRb = $window.FindName("useDarkRb")
$useDarkRb.Add_Click({
    $script:sunEnabled = 0
    getTheme | setTheme
})

#useLightRb click event
$useLightRb = $window.FindName("useLightRb")
$useLightRb.Add_Click({
    $script:sunEnabled
    getTheme | setTheme
})

#sunRb click event
$sunRb = $window.FindName("sunRb")
$sunRb.Add_Click({
    $script:sunEnabled
})

#appsCb checked/unchecked events
$appsCb = $window.FindName("appsCb")
$appsCb.Add_Click({
    $script:appsEnabled = $appsCb.IsChecked
    getTheme | setTheme
})

#systemCb checked/unchecked events
$systemCb = $window.FindName("systemCb")
$systemCb.Add_Click({
    $script:systemEnabled = $systemCb.IsChecked
    getTheme | setTheme
})

function getTheme()
{
    if ($sunRb.IsChecked) {
        $theme = [Themes]::sun
    }
    else {
        $theme = $useDarkRb.IsChecked ? [Themes]::dark : [Themes]::light
    }
    return $theme
}

$window.ShowDialog()

