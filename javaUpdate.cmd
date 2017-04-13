@echo off

:: cUrl.exe location
set cURL=\\verdc01\Software_Distribution\cURL\cURL.exe

:: check if connected to the internet
ping -n 1 google.com > nul || goto error

::----------- Find the local Java version-----------------------------------
set LocalJavaVersion=None
for /f tokens^=2-5^ delims^=.-_^" %%j in ('java -fullversion 2^>^&1') do (
	@set "LocalJavaVersionLong=%%j.%%k.%%l_%%m"
	@set "LocalJavaVersion=%%j.%%k.%%l"
)

::----------- Find the latest java version----------------------------------
set SearchJavaVersion=1.8.0
if '%LocalJavaVersion%' NEQ 'None' set SearchJavaVersion = %LocalJavaVersion%

set URL0=http://javadl-esd.sun.com/update/%SearchJavaVersion%/map-m-%SearchJavaVersion%.xml
FOR /F "tokens=2 delims=<	> " %%m IN ('%cURL% -s -L -k %URL0% ^| find /i "<url>"') DO set URL1=%%m
FOR /F "tokens=2 delims=<	> " %%m IN ('%cURL% -s -L -k %URL1% ^| find /i "<version>"') DO set RemoteJavaVersionFull=%%m
FOR /F "tokens=2 delims=<	> " %%m IN ('%cURL% -s -L -k %URL1% ^| find /i "<url>"') DO set RemoteJavaVersionURL=%%m

set RemoteJavaVersion=%RemoteJavaVersionFull:~0,-4%

:: get the OS type and change the download URL accordingly
reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=i586 || set OS=x64
call set DownloadURL=%%RemoteJavaVersionURL:-au=-%OS%%%

::----------- If no local version is found, go directly to install-----------
if '%LocalJavaVersion%'=='None' goto install

::----------- If they match, skip to the end---------------------------------
if '%RemoteJavaVersion%'=='%LocalJavaVersionLong%' goto finished

::----------- Uninstall all currently installed java versions----------------
:uninstall
:: echo Uninstalling all local versions of Java...
wmic product where "name like 'Java%%Update%%'" call uninstall /nointeractive

::----------- Download the latest java, install, delete the installer.-------
:install
\\verdc01\Software_Distribution\cURL\curl.exe -s -L -k -o %tmp%\java_inst.exe %DownloadURL%
:: echo Installing latest version of Java...
start /wait %tmp%\java_inst.exe AUTO_UPDATE=Disable REBOOT=Disable REMOVEOUTOFDATEJRES=1 SPONSORS=Disable /s
ping 127.0.0.1 > nul
del %tmp%\java_inst.exe

::----------- Up to date ----------------------------------------------------
:finished

::----------- There was an error---------------------------------------------
goto noerror
:error
echo There was a network error. Please try again.
:noerror
FOR /L %%n IN (1,1,10) DO ping -n 2 127.0.0.1 > nul & <nul set /p =.
