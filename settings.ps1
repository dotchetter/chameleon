
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
   
    Logic for settings dialog window
#>

Import-Module .\helpers.ps1
enum Themes { light; dark; sun }

class Settings
{
    static [string]$path = "settings"
	[bool]$appsEnabled
	[bool]$systemEnabled
	[Themes]$selectedTheme
	Settings()
	{
		$this.appsEnabled = $true
		$this.systemEnabled = $true
		$this.selectedTheme = [Themes]::sun
	}

    static [Settings] load()
    {
        if (Test-Path ([Settings]::path)) {
            return Get-Content -Path ([Settings]::path) -Raw | ConvertFrom-Json
        }
        else {
            return [Settings]::new()
        }
    }

    [void] save()
    {
        $this | ConvertTo-Json | Set-Content -Path ([Settings]::path)
    }

	[bool]sunEnabled()
	{
		return ($this.selectedTheme -eq [Themes]::sun)
	}

    [void]setTheme([Themes]$theme)
    {
        if ($theme -eq [Themes]::light) {
            $regValue = 1
        }
        else {
            $regValue = 0
        }
        if ($this.systemEnabled) {
            New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value $regValue -Type Dword -Force | Out-Null  
        }
        if ($this.appsEnabled) {
            New-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value $regValue -Type Dword -Force | Out-Null 
        }
    }

    [void]setTheme()
    {
        $theme = $this.selectedTheme
        if ($theme -eq [Themes]::sun) {
            $theme = Receive-Job -job $script:chameleonDaemon
            #$Receive-Job will return null if job has not updated the output since last call
            if ($null -eq $theme) {
                $theme = $script:sunTheme
            }
            else {
                $script:sunTheme = $theme
            }
        }
        $this.setTheme($theme)
    }
}

#$settings = [Settings]::load()
#$settings

function showSettings([PSCustomObject]$settings)
{
     #Create window
    [xml]$xaml = Get-Content ".\settings.xaml"
    $reader = (New-Object System.Xml.XmlNodeReader $xaml)
    $settingsWindow = [Windows.Markup.XamlReader]::Load($reader)

    #useDarkRb click event
    $useDarkRb = $settingsWindow.FindName("useDarkRb")
    $useDarkRb.Add_Click( {
        $settings.selectedTheme = [Themes]::dark
        $settings.setTheme()
        $settings.save()
    })

    #useLightRb click event
    $useLightRb = $settingsWindow.FindName("useLightRb")
    $useLightRb.Add_Click( {
        $settings.selectedTheme = [Themes]::light
        $settings.setTheme()
        $settings.save()
    })

    #sunRb click event
    $sunRb = $settingsWindow.FindName("sunRb")
    $sunRb.Add_Click( {
        $settings.selectedTheme = [Themes]::sun
        $settings.setTheme()
        $settings.save()
    })

    switch ($settings.selectedTheme) {
        dark { $useDarkRb.IsChecked = $true }
        light { $useLightRb.IsChecked = $true } 
        sun { $sunRb.IsChecked = $true } 
    }

    #appsCb click events
    $appsCb = $settingsWindow.FindName("appsCb")
    $appsCb.Add_Click( {
        $settings.appsEnabled = $appsCb.IsChecked
        $settings.setTheme()
        $settings.save()
    })
    $appsCb.IsChecked = $settings.appsEnabled
	

    #systemCb click events
    $systemCb = $settingsWindow.FindName("systemCb")
    $systemCb.Add_Click( {
        $settings.systemEnabled = $systemCb.IsChecked
        $settings.setTheme()
        $settings.save()
    })
    $systemCb.IsChecked = $settings.systemEnabled
    $settingsWindow.ShowDialog()
}

