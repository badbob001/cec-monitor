@echo off
taskkill /f /im "cec-client.exe"
echo standby 0 | cec-client
