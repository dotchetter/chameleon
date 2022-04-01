# Chameleon
![chameleon](https://user-images.githubusercontent.com/36161882/111233119-ad3a7e80-85ec-11eb-8c51-780ae0052a3c.png)

### Sync Windows 10 with sun hours at your location 

Chameleon is a daemon written for Windows 10 which automatically switches between 'Dark' and 'Light' mode depending on sunrise and sunset.
It runs in the background and automatically refreshes it's sun hour dataset once per day. 

### Toggle manually
Either you let Chameleon do the switching, or you can quick toggle between dark and light mode in Windows 10 with the buttons by right-clicking
on the Chameleon icon in your taskbar. 

![unknown](https://user-images.githubusercontent.com/36161882/111232969-68aee300-85ec-11eb-8ac7-fba953a9f807.png)

### Installation
* Download the latest release here: https://github.com/dotchetter/chameleon/archive/refs/heads/main.zip
* Open a PowerShell terminal as Admin and set the ExecutionPolicy to 'bypass': `Set-ExecutionPolicy Bypass`
* Double klick **Chameleon.exe**
* **Note:** Chameleon.exe **must** reside in it's original folder to work - either that, or move the associated .ps1 files along.
* Use the Windows scheduler to start Chameleon when the computer starts for a seamless experience.

### Disclaimers
Location data is shared with 3rd parties when using Chameleon. Upon starting the program you're consenting to this fact by using the software.
This software is under no warranty whatsoever and is strictly for entertainment purposes. 

### References
Sun hours API used: https://api.sunrise-sunset.org
