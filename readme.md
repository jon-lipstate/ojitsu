# OJITSU

Note: Initial development is planned only on Windows.

## Objective
- Runtime JIT Assembler for Odin
- Exportable as a C Header Library
- Bindable as DLL
- Use fn-ptrs for runtime linking
- Multiplatform (Win/Nix) / MultiArch Support (x64, ARM)
- Export nasm (?) text files for debug purposes

## Design Goals
- Low-Level
  - No Abstractions over the asm
  - look & feel of writing nasm (to the extent possible)
- Ergonomic user-abi, procedures mimic asm mneumonics  (`mov(...)`), engine can dismabiguate which specific asm call it is.
- Assembler holds an array of procedures, does not write entrypoints (eg `global _start`)
- Will not support deprecated asm instructions
  - Keep project size minimal
- IN WORK
