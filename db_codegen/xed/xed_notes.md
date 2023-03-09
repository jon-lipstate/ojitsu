# XED Parser

[XED](https://github.com/intelxed/xed/blob/main/datafiles/xed-isa.txt)

80r7 := 0x80 /7.

IFORM is "CMP_GPR8_IMMb_80r7". This indicates that the instruction is a comparison (CMP) between an 8-bit general-purpose register (GPR8) and an immediate 8-bit value (IMMb), using the 80r7 opcode.

## ATTRIBUTES
- LOCKED: The instruction is a locked operation, meaning that the memory location accessed by the instruction is locked for atomicity.
- HLE_ACQ_ABLE: The instruction can participate in Hardware Lock Elision (HLE) acquisition.
- HLE_REL_ABLE: The instruction can participate in HLE release.

## PATTERN
- "0x81": This is the opcode of the instruction, represented in hexadecimal format.
- "MOD[mm]": This specifies that the mod field in the instruction's ModRM byte can take any value except 3, and that the mm bits should be used to encode the memory addressing mode.
- "REG[0b000]": This specifies that the three least significant bits of the instruction's ModRM byte should be set to 000, indicating that the instruction performs an addition operation.
- "RM[nnn]": This specifies that the three most significant bits of the instruction's ModRM byte should encode the register used as the second operand in the addition operation.
- "MODRM()": This specifies that the instruction's ModRM byte should be present and contain the necessary information for the instruction to operate correctly.
- "SIMMz()": This specifies that the instruction has a sign-extended immediate operand of size z, which is determined by the mm bits in the ModRM byte and the operand-size attribute of the instruction.
- "lock_prefix": This specifies that the LOCK prefix can be used with this instruction to ensure atomicity in a multiprocessor environment.

## Attributes

HLE_ACQ_ABLE LOCKABLE ATT_OPERAND_ORDER_EXCEPTION NOP PROTECTED_MODE IMPLICIT_ONE REP NOTSX_COND INDIRECT_BRANCH BYTEOP EXCEPTION_BR RING0 fixed_MPX_PREFIX_ABLE NOTSX fixed_HLE_REL_ABLE SCALABLE LOCKED FAR_XFER

## Pattern
IMMUNE_REXW() REP=3 lock_prefix MODE_SHORT_UD0=1 UIMMv() BRDISPz() CET_NO_TRACK() REG[0b001] MEMDISPv() MOD[mm]MOD=3 norep REP=2 UIMM8_1() not64 OVERRIDE_) MODE_SHORT_UD0=0 MODEP5=1 CR_WIDTH()  SRM=0 mode16 repne no66_prefix eamode16 DF64() IMMUNE66() RM[nnn] nolock_prefix SRM[0b000] SIMM8() BRDISP8() MOD[0b11] MOD!=3 REG[0b000] ONE() REG[0b101] mode32 eamode64 SRM[rrr] OVERRIDE_SEG1() UIMM8() rexb_prefix repe P4=0 REG[0b011] eamode32 66_prefix REG[0b100] BRDISP32() REG[rrr] MODRM() SIMMz() mode64 UIMM16() not_refining_f3 REG[0b111] BRANCH_HINT() norexw_prefix REG[0b010] rexw_prefix IMMUNE66_LOOP64() FORCE64() refining_f3 REMOVE_SEGMENT() REG[0b110] norexb_prefix

## Category
FLAGOP STRINGOP CMOV LOGICAL ROTATE SHIFT SYSCALL SEMAPHORE BINARY RET POP CALL SEGOP UNCOND_BR SETCC SYSRET WIDENOP DATAXFER SYSTEM COND_BR PUSH CONVERT INTERRUPT MISC NOP IOSTRINGOP IO DECIMAL BITBYTE

## ISA_SET
I386 RDPMC CMOV I186 PPRO_UD0_SHORT I86 LONGMODE PPRO I486REAL I486 PENTIUMREAL PPRO_UD0_LONG I286REAL FAT_NOP LAHF I286PROTECTED

## FLAGS
 IMM1 MUST # MAY READONLY IMMx

 ## Operands 
 - Assignments:
 - - REG1 BASE1 REG0 REG2 REG6 REG3 INDEX REG7 BASE0 SEG0 SCALE REG5 REG4 REG8 SEG1 MEM0 MEM1 IMM0

 - Suffixes
 - - :SUPP :IMPL :rcw  :r:d :rw :b :r :cr :w :spw :z :p a32 :ECOND 
 - - CR_R() ArDI() DR_R() GPRv_B() GPRv_R() SEG_MOV() ArSI() FINAL_ESEG() GPR16_B() OeAX() FINAL_DSEG() GPRv_SB() OrDX() GPR8_R() GPR32_R() OrAX() FINAL_DSEG1() OrSP() GPR8_B() GPR64_B() SEG() GPRz_B() ArCX() OrBP() GPRz_R() rIP() GPR32_B() ArBX() ArBP() GPR16_R() GPR8_SB() FINAL_ESEG1()  
 - - AGEN RELBR FINAL_S PTR 
 - - Prefixed by: XED_REG_ 
 - - - TR EAX CR0 CR0 DX AL EBP SS  DS DI RSP FS MSRS AX STACKPUSH LDTR EDX AH BX EIP GDTR CX STACKPOP CL INVALID ECX ESI SI SP EBX GS ES BP IP EDI RIP TSC IDTR RDX ESP CS