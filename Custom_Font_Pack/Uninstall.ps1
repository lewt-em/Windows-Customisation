<#
	Remove Custom Font Pack
	-----------------------
    This script will uninstall all fonts contained within the same folder as this script.
	It will also renmove the log file created in C:\ProgramData

	PKG CREATION
    1. Create Intunewin Package
    2. Set uninstall Path
    3. Set File Execution as - powershell.exe -ExecutionPolicy Bypass -File Uninstall.ps1
#>

$detectionFile = "$($env:PROGRAMDATA)\Custom_Font_Pack_v1.0.txt"
$fontSource = $PWD.Path
$systemFontsPath = "C:\Windows\Fonts"
$systemRegPath = "HKLM:\Software\Microsoft\Windows NT\CurrentVersion\Fonts"
$getFonts = Get-ChildItem $fontsSource -Include '*.ttf','*.ttc','*.otf' -recurse

foreach($fontFile in $getFonts) {
	$targetPath = Join-Path $systemFontsPath $fontFile.Name
	if(Test-Path -Path $targetPath){
		" Removing font " + $FontFile.Name
		## Extract Font information for Reqistry
		$ShellFolder = (New-Object -COMObject Shell.Application).Namespace($fontSource)
		$ShellFile = $ShellFolder.ParseName($FontFile.name)
		$ShellFileType = $ShellFolder.GetDetailsOf($ShellFile, 2)
		## Set the $FontType Variable for registry removal
		If ($ShellFileType -Like '*TrueType font file*') {$FontType = '(TrueType)'}
		## Update Registry > Remove Font from registry and system font directory
		$RegName = $ShellFolder.GetDetailsOf($ShellFile, 21) + ' ' + $FontType
		$null = Remove-ItemProperty -Name $RegName -Path $systemRegPath -Force -ErrorAction Ignore
		" removed item $RegName from Registry"
		## Remove Font File from C:\Windows\Fonts
		$InstalledFontName=$fontFile.Name
		$FontPath = $systemFontsPath + "\" + $InstalledFontName
		Remove-Item -Path $FontPath
		" removed item $InstalledFontName from $systemFontsPath"
		" Done "
	}
	else {
		" Font not installed"
	}
}

## Remove Log File for Detection Rules in PROGRAMDATA\Custom_Font_Pack.txt
Remove-Item -Path $detectionFile
