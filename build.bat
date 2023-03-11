@echo off
cd %~dp0
odin build . -o:none -out:jit.exe -debug