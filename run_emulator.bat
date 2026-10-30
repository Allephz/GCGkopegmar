@echo off
cd /d "C:\Users\Nadja\AppData\Local\Android\Sdk\emulator"
echo Launching Android Emulator (Pixel 8a)...
start emulator.exe -avd Pixel_8a_API_35
echo Done. Closing in 3 seconds...
timeout /t 3 >nul
exit
