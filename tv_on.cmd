@echo off
taskkill /f /im "cec-client.exe"
echo on 0 | cec-client -s