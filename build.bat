@echo off
cd %~dp0
odin run . -collection:profiling=profiling -out:jit.exe -debug