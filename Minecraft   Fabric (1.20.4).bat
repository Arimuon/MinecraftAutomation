@ECHO OFF
:: This script is for Windows only (ONLY Windows 10.0.17063 or later, otherwise it will not work)
:: This script will automatically download, install, and launch the Minecraft Launcher, Java, and Fabric for Minecraft 1.20.4
:: Made by Arimuon, report issues on GitHub: https://github.com/Arimuon/MinecraftAutomation/issues

:: Script configuration settings
set "DownloadFolder=%USERPROFILE%\Downloads"
:: Java Version
set "JavaInstaller=openjdk-22.0.1_windows-x64_bin.zip"
set "JavaURL=https://download.java.net/java/GA/jdk22.0.1/c7ec1332f7bb44aeba2eb341ae18aca4/8/GPL/openjdk-22.0.1_windows-x64_bin.zip"
:: Minecraft Information
set "MinecraftVersion=%MinecraftVersion%"
set "MinecraftInstaller=%MinecraftInstaller%"
:: Fabric Versions
set "FabricInstaller=fabric-installer-1.0.1.jar"
set "FabricURL=https://maven.fabricmc.net/net/fabricmc/fabric-installer/1.0.1/fabric-installer-1.0.1.jar"
set "FabricAPIURL=https://www.curseforge.com/minecraft/mc-mods/fabric-api/download/5253510"
set "FabricExecutable=fabric-installer-1.0.1.exe"

:: Main script
ECHO Minecraft + Fabric %MinecraftVersion% Script *no admin*
:: Changes the directory to the download folder where the installer is downloaded to
cd "%DownloadFolder%"

:: Opens the default browser to the Minecraft altnerative download page and automatically start the download
start "" "https://launcher.mojang.com/download/%MinecraftInstaller%"

start "" "%JavaURL%"



:: Wait for the download to complete
:: Checks if Minecraft installer is downloaded and Java is downloaded
:LOOP3
IF NOT EXIST "%DownloadFolder%\%MinecraftInstaller%" (
    ECHO Waiting for Minecraft installer to download...
    timeout /t 5 /nobreak >NUL
    GOTO LOOP3
)
IF NOT EXIST "%DownloadFolder%\%JavaInstaller%" (
    ECHO Waiting for Java installer to download...
    timeout /t 5 /nobreak >NUL
    GOTO LOOP3
)

:: Install Java
ECHO Installing Java...
:: Unzip the Java installer
powershell -command "Expand-Archive -Path %DownloadFolder%\%JavaInstaller% -DestinationPath %DownloadFolder%\runtime\java-runtime-gamma -Force"
:: Set the JAVA_HOME environment variable
set "JAVA_HOME=%DownloadFolder%\runtime\java-runtime-gamma\windows-x64\java-runtime-gamma"
:: Add the Java bin directory to the PATH environment variable
set "PATH=%PATH%;%JAVA_HOME%\bin"

:: Delete the Java installer
del "%DownloadFolder%\%JavaInstaller%"

:: Launch Minecraft
ECHO Launching Minecraft launcher...
start "" "%DownloadFolder%\%MinecraftInstaller%"

ECHO Minecraft installation complete!
ECHO .
ECHO Please login then close the launcher
ECHO Then install Minecraft %MinecraftVersion%
ECHO After that, the script will automatically install Fabric
ECHO.

:: Wait for the user to close the launcher
:LOOP
:: Check if the Minecraft launcher/game is still running
tasklist /FI "IMAGENAME eq %MinecraftInstaller%" 2>NUL | find /I /N "%MinecraftInstaller%">NUL
IF "%ERRORLEVEL%"=="0" (
    :: If the launcher/game is still running, wait for 5 seconds and check again
    ECHO .
    ECHO Please login then close the launcher
    ECHO Then install Minecraft %MinecraftVersion%
    ECHO After that, the script will automatically install Fabric
    ECHO.
    timeout /t 1 /nobreak >NUL
    GOTO LOOP
)



:: Installing Fabric
ECHO Installing Fabric...
:: Downloading Fabric installer
start "" "%FabricURL%"

:: Wait for the download to complete
timeout /t 3 /nobreak >NUL

:: Open the Fabric installer with the installed Java
java -jar "%DownloadFolder%\%FabricInstaller%"


:: Wait for the user to close the Fabric installer
:LOOP2
:: Check if the Fabric installer is still running
tasklist /FI "IMAGENAME eq %FabricExecutable%" 2>NUL | find /I /N "%FabricExecutable%">NUL
IF "%ERRORLEVEL%"=="0" (
    :: If the installer is still running, wait for 5 seconds and check again
    timeout /t 5 /nobreak >NUL
    GOTO LOOP2
)
ECHO Fabric installation complete!

:: Delete the Fabric installer
del "%DownloadFolder%\%FabricInstaller%"

:: Create Minecraft Mods folder
IF NOT EXIST "%USERPROFILE%\AppData\Roaming\.minecraft\mods" (
    mkdir "%USERPROFILE%\AppData\Roaming\.minecraft\mods"
)
set "ModsFolder=%USERPROFILE%\AppData\Roaming\.minecraft\mods"

cd "%ModsFolder%"
:: Download the Fabric API mod to the mods folder
ECHO Downloading Fabric API mod...
start "" "https://www.curseforge.com/minecraft/mc-mods/fabric-api/download/5253510"
:: Move the Fabric API mod from the Downloads folder to the Mods folder
move "%USERPROFILE%\Downloads\fabric-api-0.97.0+%MinecraftVersion%.jar" "%ModsFolder%"

:: Keeps the terminal open to see the output/error messages
pause
:: End of script