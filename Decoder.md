# Decoder

[Intel ISMs](https://www.intel.com/content/www/us/en/developer/articles/technical/intel-sdm.html)

## Opcode Column

The "Opcode" column gives the complete object code produced for each form of the instruction.
When possible, the codes are given as hexadecimal bytes, in the same order in which they appear
in memory. Definitions of entries other than hexadecimal bytes are as follows:

**/digit** - A digit between 0 and 7 indicates that the ModR/M byte of the instruction uses
only the r/m (register or memory) operand. The reg field contains the digit that provides an
extension to the instruction's opcode.

**/r** - Indicates that the ModR/M byte of the instruction contains both a register operand and
an r/m operand.

**cb, cw, cd, cp** - A 1-byte (cb), 2-byte (cw), 4-byte (cd), or 6-byte (cp) value following the
opcode that is used to specify a code offset and possibly a new value for the code segment
register.

**ib, iw, id** - A 1-byte (ib), 2-byte (iw), or 4-byte (id) immediate operand to the instruction
that follows the opcode, ModR/M bytes or scale-indexing bytes. The opcode determines if
the operand is a signed value. All words and doublewords are given with the low-order byte first.

**+rb, +rw, +rd** - A register code, from 0 through 7, added to the hexadecimal byte given at
the left of the plus sign to form a single opcode byte. The register codes are given in Table
3-1.

**+i** - A number used in floating-point instructions when one of the operands is ST(i) from
the FPU register stack. The number i (which can range from 0 to 7) is added to the
hexadecimal byte given at the left of the plus sign to form a single opcode byte.

## Instruction Column

The "Instruction" column gives the syntax of the instruction statement as it would appear in an
ASM386 program. The following is a list of the symbols used to represent operands in the
instruction statements:

**rel8** - A relative address in the range from 128 bytes before the end of the instruction to
127 bytes after the end of the instruction.
**rel16 and rel32** - A relative address within the same code segment as the instruction
assembled. The rel16 symbol applies to instructions with an operand-size attribute of 16
bits; the rel32 symbol applies to instructions with an operand-size attribute of 32 bits.
**ptr16:16 and ptr16:32** - A far pointer, typically in a code segment different from that of
the instruction. The notation 16:16 indicates that the value of the pointer has two parts. The
value to the left of the colon is a 16-bit selector or value destined for the code segment
register. The value to the right corresponds to the offset within the destination segment.
The ptr16:16 symbol is used when the instruction's operand-size attribute is 16 bits; the
ptr16:32 symbol is used when the operand-size attribute is 32 bits.
**r8** - One of the byte general-purpose registers AL, CL, DL, BL, AH, CH, DH, or BH.
**r16** - One of the word general-purpose registers AX, CX, DX, BX, SP, BP, SI, or DI.
**r32** - One of the doubleword general-purpose registers EAX, ECX, EDX, EBX, ESP, EBP,
ESI, or EDI.
**imm8** - An immediate byte value. The imm8 symbol is a signed number between -128
and +127 inclusive. For instructions in which imm8 is combined with a word or
doubleword operand, the immediate value is sign-extended to form a word or doubleword.
The upper byte of the word is filled with the topmost bit of the immediate value.
**imm16** - An immediate word value used for instructions whose operand-size attribute is
16 bits. This is a number between -32,768 and +32,767 inclusive.
**imm32** - An immediate doubleword value used for instructions whose operandsize attribute is 32 bits. It allows the use of a number between +2,147,483,647 and
-2,147,483,648 inclusive.
**r/m8** - A byte operand that is either the contents of a byte general-purpose register (AL,
BL, CL, DL, AH, BH, CH, and DH), or a byte from memory.
**r/m16** - A word general-purpose register or memory operand used for instructions whose
operand-size attribute is 16 bits. The word general-purpose registers are: AX, BX, CX,
DX, SP, BP, SI, and DI. The contents of memory are found at the address provided by the
effective address computation.
**r/m32** - A doubleword general-purpose register or memory operand used for instructions
whose operand-size attribute is 32 bits. The doubleword general-purpose registers are:
EAX, EBX, ECX, EDX, ESP, EBP, ESI, and EDI. The contents of memory are found at the
address provided by the effective address computation.
**m** - A 16- or 32-bit operand in memory.
**m8** - A byte operand in memory, usually expressed as a variable or array name, but
pointed to by the DS:(E)SI or ES:(E)DI registers. This nomenclature is used only with the
string instructions and the XLAT instruction.
**m16** - A word operand in memory, usually expressed as a variable or array name, but
pointed to by the DS:(E)SI or ES:(E)DI registers. This nomenclature is used only with the
string instructions.
**m32** - A doubleword operand in memory, usually expressed as a variable or array name,
but pointed to by the DS:(E)SI or ES:(E)DI registers. This nomenclature is used only with
the string instructions.
**m64** - A memory quadword operand in memory. This nomenclature is used only with the
CMPXCHG8B instruction.
**m128** - A memory double quadword operand in memory. This nomenclature is used only
with the Streaming SIMD Extensions.
**m16:16, m16:32** - A memory operand containing a far pointer composed of two numbers.
The number to the left of the colon corresponds to the pointer's segment selector. The
number to the right corresponds to its offset.
m16&32, m16&16, m32&32 - A memory operand consisting of data item pairs whose
sizes are indicated on the left and the right side of the ampersand. All memory addressing
modes are allowed. The m16&16 and m32&32 operands are used by the BOUND
instruction to provide an operand containing an upper and lower bounds for array indices.
The m16&32 operand is used by LIDT and LGDT to provide a word with which to load
the limit field, and a doubleword with which to load the base field of the corresponding
GDTR and IDTR registers.
**moffs8, moffs16, moffs32** - A simple memory variable (memory offset) of type byte,
word, or doubleword used by some variants of the MOV instruction. The actual address is
given by a simple offset relative to the segment base. No ModR/M byte is used in the instruction. The number shown with moffs indicates its size, which is determined by the
address-size attribute of the instruction.
**Sreg** - A segment register. The segment register bit assignments are ES=0, CS=1, SS=2,
DS=3, FS=4, and GS=5.
m32real, m64real, m80real - A single-, double-, and extended-real (respectively)
floating-point operand in memory.
m16int, m32int, m64int - A word-, short-, and long-integer (respectively) floating-point
operand in memory.
**ST or ST(0)** - The top element of the FPU register stack.
**ST(i)** - The ith element from the top of the FPU register stack. (i = 0 through 7)
**mm** - An MMX technology register. The 64-bit MMX technology registers are:
MM0 through MM7.
**xmm** - A SIMD floating-point register. The 128-bit SIMD floating-point registers are:
XMM0 through XMM7.
**mm/m32** - The low order 32 bits of an MMX technology register or a 32-bit memory
operand. The 64-bit MMX technology registers are: MM0 through MM7. The contents
of memory are found at the address provided by the effective address computation.
**mm/m64** - An MMX technology register or a 64-bit memory operand. The 64-bit
MMX technology registers are: MM0 through MM7. The contents of memory are found
at the address provided by the effective address computation.
**xmm/m32** - A SIMD floating-points register or a 32-bit memory operand. The 128-bit
SIMD floating-point registers are XMM0 through XMM7. The contents of memory are
found at the address provided by the effective address computation.
**xmm/m64** - A SIMD floating-point register or a 64-bit memory operand. The 64-bit
SIMD floating-point registers are XMM0 through XMM7. The contents of memory are
found at the address provided by the effective address computation.
**xmm/m128** - A SIMD floating-point register or a 128-bit memory operand. The 128-bit
SIMD floating-point registers are XMM0 through XMM7. The contents of memory are
found at the address provided by the effective address computation.