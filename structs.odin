package ojitsu
// Label is empty struct, becomes an address during assembly.
Label :: struct {} // TODO: Address Forward usage for labels, jump ahead in the bitstream before label has been placed & addr known, handle with temp map to patch up after??
Procedure :: struct {
	buf: [dynamic]Instruction,
}
Asm :: struct {
	// Convention: procs[0] is always the 'main' proc
	procs: []Procedure,
}
Reg :: struct {
	reg:    GeneralPurpose,
	offset: Offset,
}
Offset :: struct {
	add: u16,
	mul: u8, // can only be 1,2,4,8
}
// TODO: add Size?
Operand :: union {
	// Naked Registers
	GeneralPurpose,
	// Offset Registers
	Reg,
	Mem,
	Imm,
	Label,
}
RegMem :: union {
	Reg,
	Mem,
}
MemReal :: struct {} // m32real, m64real, m80real
Mem :: struct {
	addr:   u64, // ??
	offset: Offset,
}
MemPtr :: struct {} // m16:16, m16:32
Imm :: union {
	u8,
	u16,
	u32,
	u64,
}
Rel :: struct {}
Ptr :: struct {} // jmp far [bx+si+0x7401]   jnz near 0x4856
MOff :: struct {}

// `zax` - mapped to either `eax` or `rax` Z prefix for native size

// ["mov, "W:r64/m64, r64", "MR", "REX.W 89 /r"   , "X64 XRelease"],
// ["mov, "W:r64/m64, id" , "MI", "REX.W C7 /0 id", "X64 XRelease"],
// ["mov, "W:r64, r64/m64", "RM", "REX.W 8B /r"   , "X64"],

GeneralPurpose :: enum {
	RAX,
	R0,
	EAX,
	R0D,
	AX,
	R0W,
	AH,
	AL,
	R0B,
	//
	RCX,
	R1,
	ECX,
	R1D,
	CX,
	R1W,
	CH,
	CL,
	R1B,
	//
	RDX,
	R2,
	EDX,
	R2D,
	DX,
	R2W,
	DH,
	DL,
	R2B,
	//
	RBX,
	R3,
	EBX,
	R3D,
	BX,
	R3W,
	BH,
	BL,
	R3B,
	//
	RSP,
	R4,
	ESP,
	R4D,
	SP,
	R4W,
	SPL,
	R4B,
	//
	RBP,
	R5,
	EBP,
	R5D,
	BP,
	R5W,
	BPL,
	R5B,
	//
	RSI,
	R6,
	ESI,
	R6D,
	SI,
	R6W,
	SIL,
	R6B,
	//
	RDI,
	R7,
	EDI,
	R7S,
	DI,
	R7W,
	DIL,
	R7B,
	// REX REGISTERS:
	R8,
	R8D,
	R8W,
	R8B,
	//
	R9,
	R9D,
	R9W,
	R9B,
	//
	R10,
	R10D,
	R10W,
	R10B,
	//
	R11,
	R11D,
	R11W,
	R11B,
	//
	R12,
	R12D,
	R12W,
	R12B,
	//
	R13,
	R13D,
	R13W,
	R13B,
	//
	R14,
	R14D,
	R14W,
	R14B,
	//
	R15,
	R15S,
	R15W,
	R15B,
}
