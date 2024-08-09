@echo off

REM Close the game using taskkill
taskkill /f /im "RiotClientServices.exe" /t
taskkill /f /im "League of Legends.exe" /t