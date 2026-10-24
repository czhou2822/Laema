@echo off
if not exist "%~dp0output" mkdir "%~dp0output"
explorer.exe "%~dp0output"
