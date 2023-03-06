# asmdb codegen

This directory contains parsers & code generation that produces the instruction set. material is sourced from [AsmDB](https://github.com/asmjit/asmdb) which is licensed as public domain.

All caps files such as `OPCODE.json` are extracts of the dataset for that particular column, allowing for parser-testing. corresponding Odin files are dedicated to parsing that column of data.

AsmDb's base data is contained in `x86data.json`.