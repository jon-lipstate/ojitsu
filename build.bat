@echo off
cd %~dp0
odin build . -o:minimal -out:jit.exe -debug