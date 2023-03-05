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
// TODO: Union with XMM?
mod_rm_value := map[GeneralPurpose]u8 {
	.RAX  = 0b000,
	.R0   = 0b000,
	.EAX  = 0b000,
	.R0D  = 0b000,
	.AX   = 0b000,
	.R0W  = 0b000,
	.AH   = 0b000,
	.AL   = 0b000,
	.R0B  = 0b000,
	//
	.RCX  = 0b001,
	.R1   = 0b001,
	.ECX  = 0b001,
	.R1D  = 0b001,
	.CX   = 0b001,
	.R1W  = 0b001,
	.CH   = 0b001,
	.CL   = 0b001,
	.R1B  = 0b001,
	//
	.RDX  = 0b010,
	.R2   = 0b010,
	.EDX  = 0b010,
	.R2D  = 0b010,
	.DX   = 0b010,
	.R2W  = 0b010,
	.DH   = 0b010,
	.DL   = 0b010,
	.R2B  = 0b010,
	//
	.RBX  = 0b011,
	.R3   = 0b011,
	.EBX  = 0b011,
	.R3D  = 0b011,
	.BX   = 0b011,
	.R3W  = 0b011,
	.BH   = 0b011,
	.BL   = 0b011,
	.R3B  = 0b011,
	//
	.RSP  = 0b100,
	.R4   = 0b100,
	.ESP  = 0b100,
	.R4D  = 0b100,
	.SP   = 0b100,
	.R4W  = 0b100,
	.SPL  = 0b100,
	.R4B  = 0b100,
	//
	.RBP  = 0b101,
	.R5   = 0b101,
	.EBP  = 0b101,
	.R5D  = 0b101,
	.BP   = 0b101,
	.R5W  = 0b101,
	.BPL  = 0b101,
	.R5B  = 0b101,
	//
	.RSI  = 0b110,
	.R6   = 0b110,
	.ESI  = 0b110,
	.R6D  = 0b110,
	.SI   = 0b110,
	.R6W  = 0b110,
	.SIL  = 0b110,
	.R6B  = 0b110,
	//
	.RDI  = 0b111,
	.R7   = 0b111,
	.EDI  = 0b111,
	.R7S  = 0b111,
	.DI   = 0b111,
	.R7W  = 0b111,
	.DIL  = 0b111,
	.R7B  = 0b111,
	// REX REGISTERS:
	.R8   = 0b000,
	.R8D  = 0b000,
	.R8W  = 0b000,
	.R8B  = 0b000,
	//
	.R9   = 0b001,
	.R9D  = 0b001,
	.R9W  = 0b001,
	.R9B  = 0b001,
	//
	.R10  = 0b010,
	.R10D = 0b010,
	.R10W = 0b010,
	.R10B = 0b010,
	//
	.R11  = 0b011,
	.R11D = 0b011,
	.R11W = 0b011,
	.R11B = 0b011,
	//
	.R12  = 0b100,
	.R12D = 0b100,
	.R12W = 0b100,
	.R12B = 0b100,
	//
	.R13  = 0b101,
	.R13D = 0b101,
	.R13W = 0b101,
	.R13B = 0b101,
	//
	.R14  = 0b110,
	.R14D = 0b110,
	.R14W = 0b110,
	.R14B = 0b110,
	//
	.R15  = 0b111,
	.R15S = 0b111,
	.R15W = 0b111,
	.R15B = 0b111,
}
