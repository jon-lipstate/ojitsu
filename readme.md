# OJITSU

Work In Progress

## Objective
- Runtime JIT Assembler for Odin
- Exportable as a C Header Library
- Static Library?
- Use fn-ptrs for runtime linking
- Multiplatform (Win/Nix) / MultiArch Support (x64, ARM)
- Export `listing` string/files for Debug use
- **Encode Only**, architecture is not intended for any form of decode

## Design Goals
- Low-Level
  - No Abstractions over the asm
  - look & feel of writing nasm (to the extent possible)
- Ergonomic user-abi, procedures mimic asm mneumonics  (`mov(...)`), engine can dismabiguate which specific asm call it is.
- Assembler holds an array of procedures, does not write entrypoints (eg `global _start`)
- Instructions are added as-needed to keep project size minimal (XED is 13 mb)
- - Possibly use subpackage imports by extension (?)

## Todos/Ideas
- Use a Symbol/Relocation table in order to pre-compute instruction lengths

  - Permit ability to auto-insert `nop`s for alignment

- Symbol Table also allows Forward Declared Labels
- Rust uses I/O declarations, good idea?

  - Pro is that it allows arch-independant proc declarations
  - Con is that it obfuscates register usage into an alias - Done with macros 

     - Odin may not have a nice way to represent this
- use a cli on generated code to build minimal sized libs?



```rust
use std::arch::asm;
let i: u64 = 3;
let o: u64;
asm!("mov {0}, {1}","add {0}, 5",out(reg) o,in(reg) i,);
let mut x: u64 = 3;
asm!("add {0}, 5", inout(reg) x);
```