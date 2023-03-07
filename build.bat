@echo off
cd %~dp0
odin build . -collection:profiling=profiling -out:jit.exe -debug