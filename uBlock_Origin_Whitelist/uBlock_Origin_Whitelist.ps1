<#
    uBlock Orgin Whitelist
    ----------------
    Adds a custom whitelist for uBlock Origin to the system registry
    To modify the whitelist, add a URL via $KeyConfig

    PKG CREATION
    1. Create Intunewin Package
    2. Set Install Path
    3. Set File Execution as - powershell.exe -ExecutionPolicy Bypass -File uBlock_Origin_Whitelist.ps1

    INTUNE
	1. Upload Intunewin package
	2. Update the description with the added Whitelist entries
	3. Set Install command as powershell.exe -ExecutionPolicy Bypass -File uBlock_Origin_Whitelist.ps1
	4. Set Remove command as powershell.exe -ExecutionPolicy Bypass -File Uninstall.ps1
	5. Manually configure detection rules as File or Folder
	6. Set as file exists folder as C:\ProgramData
	7. Set File name as listed in $detectionFile
#>

# File detection
$detectionFile = "$($env:PROGRAMDATA)\uBlock_Origin_Whitelist_v1.0.txt"

# sets registry path
$RegPath = 'HKLM:\SOFTWARE\Policies\Microsoft\Edge\3rdparty\Extensions\odfafepnkmbhccpbejgmiehpchacaeak\policy'
# sets name of key to add
$AttrName = 'adminSettings'

# sets the value for the key
# To edit, flatten uBlock backup .json file, extract "whitelist":{[]} section
$KeyConfig = '{"whitelist": [ "about-scheme", "chrome-extension-scheme", "edge-scheme", "moz-extension-scheme", "opera-scheme", "vivaldi-scheme", "wyciwyg-scheme"]}'

# Check if the registry path exists
$a = test-path $RegPath

# Remdiation
if ($a -eq $true) {
	Remove-ItemProperty -Path $RegPath -Name $AttrName
	New-Item $RegPath -force
	Set-ItemProperty -Path $RegPath -Name $AttrName -value $KeyConfig -force
} else {
	New-Item $RegPath -force
	Set-ItemProperty -Path $RegPath -Name $AttrName -value $KeyConfig
}

# File Detection Script
Out-File -FilePath $detectionFile -InputObject "uBlock Origin Whitelist"
Add-Content -Path $detectionFile -Value "----------"
Add-Content -Path $detectionFile -Value $KeyConfig
