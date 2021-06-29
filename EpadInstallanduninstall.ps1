############################INSTALL EPAD AUTOMATICLY
#parameter check
param(
[switch] $forceuninstall,
[switch] $openurl,
[switch] $nodownload
)
#Hardcoded Values
$forceuninstall = $true
if($forceuninstall){
Write-Host "FORCE UNINSTALL INITIATED!" -ForegroundColor Red
}


#URL to reach install file
$url = "https://www.epadlink.com/software/UI12.4.R12285_setup.exe"
#Output file path + name
$output = "C:\Epad\UI12.4.R12285_setup.exe"

#URL to reach SIG install file
$urlSig = "https://www.epadlink.com/SigCaptureWeb/SigCaptureWeb.exe"
#Output file path + name
$outputSig = "C:\Epad\SigCaptureWeb.exe"

#start time of script for download time report
$start_time = Get-Date
#Destination Folder
$DestinationPath = "C:\Epad"


#Check for Folder
Write-Host "Checking for folder $DestinationPath" -ForegroundColor Yellow
if (-not (Test-Path $DestinationPath)) {
        # Destination path does not exist, let's create it
        try {
            New-Item -Path $DestinationPath -ItemType Directory -ErrorAction Stop
            Write-Host "Created folder $DestinationPath" -ForegroundColor Green
        } catch {
            throw "Could not create path '$DestinationPath'!"
        }
    }


#check 32-bit or 64bit
$OSArchitecture = (Get-WMIObject Win32_OperatingSystem).OSArchitecture

#look in registry for uninstall string
if($OSArchitecture -eq "64-bit"){
$uninstallSigcapture = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {($_.Publisher -eq "ePadLink") -and ($_.DisplayName -like "SigCaptureWeb*")}
$uninstallEpadlink = Get-ItemProperty HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | where {($_.Publisher -eq "ePadLink") -and ($_.DisplayName -like "epadLink ePad*") -and ($_.UninstallString -Like "*C:\Program Files*")}
}

if($OSArchitecture -eq "32-bit"){
$uninstallSigcapture = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {($_.Publisher -eq "ePadLink") -and ($_.DisplayName -like "SigCaptureWeb*")}
$uninstallEpadlink = Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | where {($_.Publisher -eq "ePadLink") -and ($_.DisplayName -like "epadLink ePad*") -and ($_.UninstallString -Like "*C:\Program Files*")}
}



#Check for Version 
if(($($uninstallSigcapture.DisplayVersion) -ne "1.2") -or ($forceuninstall)){
[bool] $RemoveSig = $true
Write-Host $($uninstallSigcapture.DisplayName)
Write-Host "Version: " $($uninstallSigcapture.DisplayVersion) 
Write-Host "Version out of date Will Uninstall old" -ForegroundColor Red
}
else{
[bool] $RemoveSig = $false
Write-Host $($uninstallSigcapture.DisplayName)
Write-Host "Version: " $($uninstallSigcapture.DisplayVersion)
Write-Host "Version Up to date" -ForegroundColor Green
}

if(($($uninstallEpadlink.DisplayVersion) -ne "12.4.12285") -or ($forceuninstall)){
[bool] $RemoveUI = $true
Write-Host $($uninstallEpadlink.DisplayName)
Write-Host $($uninstallEpadlink.DisplayVersion)
Write-Host "Version out of date Will Uninstall old" -ForegroundColor Red
}
else{
[bool] $RemoveUI = $false
Write-Host $($uninstallEpadlink.DisplayName)
Write-Host $($uninstallEpadlink.DisplayVersion)
Write-Host "Version Up to date" -ForegroundColor Green
}

if($nodownload -eq $false){
#Download Epad UI from repo
Write-Host "Starting download of $url" -ForegroundColor Blue
Invoke-WebRequest -Uri $url -OutFile $output
Write-Host "File Downloaded in: $((Get-Date).Subtract($start_time).Seconds) second(s)" -ForegroundColor Blue

#Download Epad Sig SDK
Write-Host "Starting download of $urlSig" -ForegroundColor Blue
Invoke-WebRequest -Uri $urlSig -OutFile $outputSig
Write-Host "File Downloaded in: $((Get-Date).Subtract($start_time).Seconds) second(s)" -ForegroundColor Blue
}


#create Response FIles for uninstall
Write-Host "Building Response.in Files!" -ForegroundColor Yellow
#Create Response File for UI
Set-content -Path "C:\Epad\Response.in" -Value "
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-DlgOrder]
Dlg0={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdWelcome-0
Count=7
Dlg1={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdLicense2Rtf-0
Dlg2={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdCustomerInfo-0
Dlg3={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdSetupType-0
Dlg4={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdStartCopy2-0
Dlg5={9B954C9B-2842-42B7-A815-6C4D05FA649F}-MessageBox-0
Dlg6={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdFinish-0
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdWelcome-0]
Result=1
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdLicense2Rtf-0]
Result=1
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdCustomerInfo-0]
szName=Admin
szCompany=MHC
nvUser=1
Result=1
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdSetupType-0]
szDir=C:\Program Files (x86)\ePadLink\ePad\
Result=301
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdStartCopy2-0]
Result=1
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-MessageBox-0]
Result=1
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"
#Create Response file for Sig
Set-content -Path "C:\Epad\ResponseSig.in" -Value "
[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-DlgOrder]
Dlg0={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdWelcome-0
Count=5
Dlg1={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdLicense-0
Dlg2={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdRegisterUser-0
Dlg3={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdAskDestPath-0
Dlg4={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdFinish-0
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdWelcome-0]
Result=1
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdLicense-0]
Result=1
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdRegisterUser-0]
szName=Admin
szCompany=MHC
Result=1
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdAskDestPath-0]
szDir=C:\Program Files (x86)\SigCaptureWeb SDK
Result=1
[Application]
Name=SigCaptureWeb SDK
Version=1.2
Company=ePadLink
Lang=0409
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"
#create Response files for uninstall Sig
Set-content -Path "C:\Epad\ResponseSigUninstall.in" -Value "[InstallShield Silent]
Version=v7.00
File=Response File
[File Transfer]
OverwrittenReadOnly=NoToAll
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-DlgOrder]
Dlg0={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdWelcomeMaint-0
Count=3
Dlg1={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SprintfBox-0
Dlg2={FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdFinish-0
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdWelcomeMaint-0]
Result=303
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SprintfBox-0]
Result=1
[Application]
Name=SigCaptureWeb SDK
Version=1.2
Company=ePadLink
Lang=0409
[{FCEDF7DA-0B26-49C0-A3B9-22CCF341C7B1}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"
#create Response files for uninstall epad UI
Set-content -Path "C:\Epad\ResponseUninstall124.in" -Value "[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-DlgOrder]
Dlg0={9B954C9B-2842-42B7-A815-6C4D05FA649F}-MessageBox-0
Count=2
Dlg1={9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdFinish-0
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-MessageBox-0]
Result=6
[{9B954C9B-2842-42B7-A815-6C4D05FA649F}-SdFinish-0]
Result=1
bOpt1=0
bOpt2=0
"
Write-Host "Response files built" -ForegroundColor Green


#install .net framework 3.5 (2.0 and 3.0)
Write-Host "Installing .net 3.5" -ForegroundColor Yellow
DISM /Online /Enable-Feature /FeatureName:NetFx3 /All /LimitAccess /Source:"Path\To\microsoft-windows-netfx3-ondemand-package"
Write-Host ".net 3.5 Installed" -ForegroundColor Green


#Uninstall Epad link
if($RemoveUI -eq $true){
Write-Host "Uninstalling Epad Link" -ForegroundColor Red

#split the uninstaller into arguments and file path
$splitUI = $($uninstallEpadlink.Uninstallstring).Split('"')
$argsUI = $splitUI[2] + " -s -f1`"C:\Epad\ResponseUninstall124.in`" "
$pathUI = $splitUI[1]

#execute uninstaller
Start-Process -FilePath $pathUI -ArgumentList $argsUI -Wait
Write-Host "EpadLink Uninstalled" -ForegroundColor Green
}

#Uninstall Sig capture 
if($RemoveSig -eq $true){
Write-Host "Uninstalling Sig Capture" -ForegroundColor Red

#split the uninstaller into arguments and file path
$splitSig = $($uninstallSigcapture.UninstallString).split('"')
$argsSig = $splitSig[2] + " -s -f1`"C:\Epad\ResponseSigUninstall.in`""
$pathSig = $splitSig[1]

#execute uninstaller
Start-Process -FilePath $pathSig -ArgumentList $argsSig -Wait
Write-Host "SigCapture Uninstalled" -ForegroundColor Green
}


#Start-Sleep -Seconds 20

#install Universal installer
Write-Host "Installing EpadLink" -ForegroundColor Yellow
Start-Process -FilePath "C:\Epad\UI12.4.R12285_setup.exe" -ArgumentList "/s /f1`"C:\Epad\Response.in`"" -Wait
Write-Host "EpadLink Installed" -ForegroundColor Green

#install SDK SIG
Write-Host "Installing SigCaptureWeb" -ForegroundColor Yellow
Start-Process -FilePath "C:\Epad\SigCaptureWeb.exe" -ArgumentList "/s /f1`"C:\Epad\ResponseSig.in`"" -Wait
Write-Host "SigCaptureWeb Installed" -ForegroundColor Green


#Check for install staus
$log = Get-Content -Path "C:\Epad\setup.log"
$ResultCode = $log | Select-String -Pattern "ResultCode"
Write-Host $ResultCode -ForegroundColor Cyan

Write-Host "Script finished in: $((Get-Date).Subtract($start_time).Seconds) second(s)" -ForegroundColor Blue

#open webpage in chrome
if($openurl){
[system.Diagnostics.Process]::Start("chrome","http://support.autoslm.net/sandbox/esign/testesign.cfm")
}

#other test webpage
#https://portal.mhcorp.com/AppClients/KioskClients


#############FIX UNINSTALL ISSUE NOT STARTING
