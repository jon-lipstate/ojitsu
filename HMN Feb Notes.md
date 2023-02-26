# HMN Meetup - Feb Notes

Presented status and plan, notes (mostly for myself) of the suggestions provided. 

## Goals

 - Main: Asm Jit Compiler
 - Runtime 'Linking' is passing in fn-ptrs
 - nice to have (Avoid design choices that prevent these):
   - c-header lib
   - DLL bindings
   - extensible to full runtime (non-optimizing?) jit compiler for odin

## Q&A
- Suggestions:
  - Move away from overloads, it wont transfer to c-headers in a nice way
  - Go for signatures like: `memreg::proc(p:^Procedure, n:Mneumonic, m:Mem, r:Reg)` where the `Mnuemonic` is `.mov`. 
    - A user-facing API layer could restore the 'nice' procs like `mov(...)`
  - Focus on engine core & dedup efforts - the current design will proliferate code-duplication (eg `switch {case 64:}` in every fn)
- Design:
  - Push-Buffer may provide insights in design, good to try out and see if it is worthwhile
    - write-on-push possibly was constraining 'vision' for the projects design
