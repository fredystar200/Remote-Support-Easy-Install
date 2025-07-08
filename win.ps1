# Remote Support Loader (by fredystar200)
$batUrl = "https://github.com/fredystar200/Remote-Support-Easy-Install/raw/main/win.bat"
$batPath = "$env:TEMP\rsedwin.bat"
Invoke-WebRequest -Uri $batUrl -OutFile $batPath
Start-Process -FilePath $batPath -Wait
