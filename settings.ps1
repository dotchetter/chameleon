Import-Module .\helpers.ps1
function initSettingsWindow()
{
    #Create window
    [xml]$xaml = Get-Content ".\settings.xaml"
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $script:settingsWindow = [Windows.Markup.XamlReader]::Load($reader)

    #useDarkRb click event
    $script:useDarkRb = $script:settingsWindow.FindName("useDarkRb")
    $script:useDarkRb.Add_Click( {
        $script:sunEnabled = 0
        getTheme | setTheme
        $script:selectedTheme = [Themes]::dark
    })

    #useLightRb click event
    $script:useLightRb = $script:settingsWindow.FindName("useLightRb")
    $script:useLightRb.Add_Click( {
        $script:sunEnabled = 0
        getTheme | setTheme
        $script:selectedTheme = [Themes]::light

    })

    #sunRb click event
    $script:sunRb = $script:settingsWindow.FindName("sunRb")
    $script:sunRb.Add_Click( {
        $script:sunEnabled = 1
        [Themes]::sun | setTheme
        $script:selectedTheme = [Themes]::sun
    })

    switch ($script:selectedTheme) {
        dark { $script:useDarkRb.IsChecked = $true }
        light { $script:useLightRb.IsChecked = $true } 
        sun { $script:sunRb.IsChecked = $true } 
    }

    #appsCb click events
    $script:appsCb = $script:settingsWindow.FindName("appsCb")
    $script:appsCb.Add_Click( {
        $script:appsEnabled = $script:appsCb.IsChecked
        getTheme | setTheme
    })
    $script:appsCb.IsChecked = $script:appsEnabled

    #systemCb click events
    $script:systemCb = $script:settingsWindow.FindName("systemCb")
    $script:systemCb.Add_Click( {
        $script:systemEnabled = $script:systemCb.IsChecked
        getTheme | setTheme
    })
    $script:systemCb.IsChecked = $script:systemEnabled
}
function getTheme()
{
    if ($sunRb.IsChecked) {
        $theme = [Themes]::sun
    }
    else {
        if ($useDarkRb.IsChecked) {
            $theme =  [Themes]::dark
         }
         else{
             $theme = [Themes]::light
         }
    }
    return $theme
}

