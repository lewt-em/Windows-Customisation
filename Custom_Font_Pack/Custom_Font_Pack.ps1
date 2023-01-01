<#
	Custom Font Pack
	----------------
	This script will install all fonts contained within the same folder as this script.
	It will also create a log file in C:\ProgramData

	PKG CREATION
    1. Create Intunewin Package
    2. Set Install Path
    3. Set File Execution as - powershell.exe -ExecutionPolicy Bypass -File Custom_Font_Pack.ps1

    INTUNE
	1. Upload Intunewin package
	2. Update the description with the added Whitelist entries
	3. Set Install command as powershell.exe -ExecutionPolicy Bypass -File Custom_Font_Pack.ps1
	4. Set Remove command as powershell.exe -ExecutionPolicy Bypass -File uninstall.ps1
	5. Manually configure detection rules as File or Folder
	6. Set as file exists folder as C:\ProgramData
	7. Set File name as listed in $detectionFile
#>

$detectionFile = "$($env:PROGRAMDATA)\Custom_Font_Pack_v1.0.txt"
$fontSource = $PWD.Path
$systemFontsPath = "C:\Windows\Fonts"
$systemRegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
$getFonts = Get-ChildItem $fontsSource -Include '*.ttf','*.ttc','*.otf' -recurse

## Create Text Log File for Detection Rules in PROGRAMDATA\Custom_Font_Pack.txt
Out-File -FilePath $detectionFile -InputObject "Custom Fonts"
Add-Content -Path $detectionFile -Value "----------"

foreach($fontFile in $getFonts) {
	$targetPath = Join-Path $systemFontsPath $fontFile.Name
	if(Test-Path -Path $targetPath){
		$FontFile.Name + " already installed"
	}
	else {
		"Installing font " + $fontFile.Name
		## Extract Font information for Reqistry
		$ShellFolder = (New-Object -COMObject Shell.Application).Namespace($fontSource)
		$ShellFile = $ShellFolder.ParseName($FontFile.name)
		$ShellFileType = $ShellFolder.GetDetailsOf($ShellFile, 2)
		## Set the $FontType Variable
		If ($ShellFileType -Like '*TrueType font file*') {$FontType = '(TrueType)'}
		## Update Registry and copy font to font directory
		$RegName = $ShellFolder.GetDetailsOf($ShellFile, 21) + ' ' + $FontType
		$null = New-ItemProperty -Name $RegName -Path $systemRegPath -PropertyType string -Value $FontFile.name -Force
		Write-Host $fontFile
		Copy-Item $fontFile.FullName -Destination $systemFontsPath
		Add-Content -Path $detectionFile -Value $fontFile
		"Done"
	}
}
