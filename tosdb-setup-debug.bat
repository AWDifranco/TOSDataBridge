@echo off

NET FILE 1>NUL 2>NUL &

IF %ERRORLEVEL% NEQ 0 (
    echo tosdb-setup-debug.bat must be run as administrator.
    EXIT /B 1
)

set bCRTfiles=false

IF EXIST C:/Windows/System32/msvcr110d.dll (
    IF EXIST C:/Windows/System32/msvcp110d.dll (
        set bCRTfiles=true
    )
)


IF /I "%2"=="admin" ( 
    set servCmd= --admin %3
) else (
    set servCmd= %2
)

IF "%1"=="x64" (  
    set vcRedist=vcredist_x64.exe
    set servBin=%cd%\\bin\\Debug\\x64\\tos-databridge-serv-x64_d.exe
    set engBin=%cd%\\bin\\Debug\\x64\\tos-databridge-engine-x64_d.exe
    set createCmd=%cd%\\bin\\Debug\\x64\\tos-databridge-serv-x64_d.exe%servCmd%       
) else ( 
    IF "%1"=="x86" (  
        IF EXIST C:/Windows/SysWOW64 set bCRTfiles=false
        IF EXIST C:/Windows/SysWOW64/msvcr110d.dll (
            IF EXIST C:/Windows/SysWOW64/msvcp110d.dll (
                set bCRTfiles=true
            )
        )
        set vcRedist=vcredist_x86.exe
        set servBin=%cd%\\bin\\Debug\\Win32\\tos-databridge-serv-x86_d.exe 
        set engBin=%cd%\\bin\\Debug\\Win32\\tos-databridge-engine-x86_d.exe
        set createCmd=%cd%\bin\Debug\Win32\tos-databridge-serv-x86_d.exe%servCmd%     
    ) else (
        echo - Invalid Command Line Argument. Use 'x86' or 'x64' to signify which build to setup.        
        EXIT /B 1
        )
)


echo + Checking for VC++ Redistributable Files ...
IF %bCRTfiles%==false (        
    echo ++ Not Found. Installing VC++ Redistributable ...
    "%vcRedist%" 
    IF ERRORLEVEL 1 (
        echo - Installation failed, exiting setup...
        EXIT /B 1
    )
)

echo + Checking for binaries...
IF NOT EXIST %servBin% (
    echo - Can't find "%servBin%", exiting setup...
    EXIT /B 1
)
IF NOT EXIST %engBin% (
    echo - Can't find "%engBin%", exiting setup...
    EXIT /B 1
)

echo + stop old TOSDataBridge Service ...
SC stop TOSDataBridge 1>NUL 2>NUL    
timeout /t 3 /nobreak
echo.

echo + delete old TOSDataBridge Service ...
SC delete TOSDataBridge 1>NUL 2>NUL   
timeout /t 3 /nobreak
echo.

echo + Creating TOSDataBridge Service ...
echo + %createCmd%
SC create TOSDataBridge binPath= "%createCmd%"

IF ERRORLEVEL 1 (
    echo - SC create failed, exiting setup...
    echo - Be sure 'Process Explorer' is not running and you are not accessing the old service.
    echo - Try running this setup script again. If that fails you may need to manually stop/delete old service:
    echo -     SC stop TOSDataBridge
    echo -     SC delete TOSDataBridge
    echo - Then run the setup script again.    
    echo - (If that fails please report the issue @ github.com/jeog/TOSDataBridge/issues)
    EXIT /B 1
)   

EXIT /B 0










