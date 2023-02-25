# HM Feb Questions

## Backstory
 - Learing about transformer models -> wrote ffnn, pytorch use asmjit, second time running into it
 - Curious about JIT Compilation
 - wrote toy (demo)
 - wrote parsers (dont know what most of it does)
 - back to basics - top 20 gp asm instr + 6 avx
 - not fully commited, mainly exploring

## Goals
 - Main: Asm Jit Compiler for math parser
 - nice to have (try to avoid design choices that prevent these):
   - c-header lib
   - extended to full runtime (non-optimizing?) jit compiler for odin

## Questions
- Design:
  - Push-Buffer vs Write-on-Push
    - consequence: Push buffer has 'burst of computation' @`assemble()` vs spread out on write on push
  - Internal switch on dest-bit size to determine code path from MR RM MI etc versions?
  - Anyone knows if Odin -> C-Header lib is reasonable to make? Avoid Map / dynamic and its okay..?
  - Bindings, whats reasonable?
    - Odin - as package only (cant export)
    - cpp - ifdef cpp{ fn overloads}
    - c - macros ..?
  - thoughts on 20+6 approach? (adding few more as needed)?

```go
@(export) // <- no can do
mov :: proc { mov_rr, mov_mr, mov_mi, mov_rm, mov_ri, mov_ro }
@(export) // <- works fine, but i want to export `mov`
mov_rr :: proc(b: ^Block, rd: Reg, rs: Reg, p: Prefixes = {}) {...}
mov_mi :: proc(b: ^Block, rm: RegMem, i: Imm, p: Prefixes = {}) {...}
```