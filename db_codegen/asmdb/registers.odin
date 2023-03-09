package asmdb_parser

RegisterFamily :: enum {
	Invalid,
	InstructionPointer,
	Gpr,
	Segment,
	Control,
	Debug,
	Bound,
	FPU_ST,
	AnyVec_MM, // ?MM, keep??
	Masks_K,
	Vec,
	Amx_Tile, // Advanced Matrix Extensions AMX-TILE
}
Size :: enum {
	Invalid,
	R8,
	R8_HI, // belongs here...?
	R16,
	R32,
	R64,
	R128,
	R256,
	R512,
}
RegInfo :: struct {
	name:   string,
	family: RegisterFamily,
	size:   Size,
	rex:    bool,
	index:  i8, // Ordering, use 255 for default / nil..?
}
//https://en.wikibooks.org/wiki/X86_Assembly/X86_Architecture#Multi-Segmented_Memory_Model

Reg :: union {
	Gpr,
	Masks,
}
Gpr :: enum {
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
Masks :: enum {
	K0,
	K1,
	K2,
	K3,
	K4,
	K5,
	K6,
	K7,
}
// RAX, R0 | EAX, R0D | AX, R0W | AH | AL , R0B
// RCX, R1 | ECX, R1D | CX, R1W | CH | CL , R1B
// RDX, R2 | EDX, R2D | DX, R2W | DH | DL , R2B
// RBX, R3 | EBX, R3D | BX, R3W | BH | BL , R3B
// RSP, R4 | ESP, R4D | SP, R4W | -- | SPL, R4B
// RBP, R5 | EBP, R5D | BP, R5W | -- | BPL, R5B
// RSI, R6 | ESI, R6D | SI, R6W | -- | SIL, R6B
// RDI, R7 | EDI, R7S | DI, R7W | -- | DIL, R7B
//
// R8  | R8D  | R8W  | R8B
// R9  | R9D  | R9W  | R9B
// R10 | R10D | R10W | R10B
// R11 | R11D | R11W | R11B
// R12 | R12D | R12W | R12B
// R13 | R13D | R13W | R13B
// R14 | R14D | R14W | R14B
// R15 | R15S | R15W | R15B
//
// RIP  | EIP  | IP

// RFLAGS | EFLAGS | FLAGS

// Masks,    K: K0..7
// Bounds, BND: BND0..3
// Shadow, CET: SSP CLP0..3 idk what this is
// https://www.sandpile.org/
// Segments: S,SS,DS,ES,FS,GS
// Tables: GDTR, IDTR,LDTR,TR
// Control:CR0..15
// Debug: DR0..15
// Legacy: FP/MMX/3DNow!
// VEX: XMM0..15 (128bit), YMM0..15 (256 bit), ZMM0..31 (512 Bit)
// MVEX: ZMM16..31
// EVEX: X,Y,Z 16..31
// SIMD Control/Status: MXCSR
