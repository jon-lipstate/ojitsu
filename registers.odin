package ojitsu
//

// GprUnsized :: RegisterGroup{.Gpr, .Unsized}
// Gpr8 :: RegisterGroup{.Gpr, .Bits_8}
// Gpr8H :: RegisterGroup{.Gpr, .Bits_8H}
// Gpr16 :: RegisterGroup{.Gpr, .Bits_16}
// Gpr32 :: RegisterGroup{.Gpr, .Bits_32}
// Gpr64 :: RegisterGroup{.Gpr, .Bits_64}

// AL :: Register{Gpr8, 0}
// AH :: Register{Gpr8H, 0}
// AX :: Register{Gpr16, 0}
// EAX :: Register{Gpr32, 0}
// RAX :: Register{Gpr64, 0}
// //
// R0B :: Register{Gpr8, 0}
// R0W :: Register{Gpr16, 0}
// R0D :: Register{Gpr32, 0}
// R0 :: Register{Gpr64, 0}
// //
// CL :: Register{Gpr8, 1}
// CH :: Register{Gpr8H, 1}
// CX :: Register{Gpr16, 1}
// ECX :: Register{Gpr32, 1}
// RCX :: Register{Gpr64, 1}

RegisterGroup :: struct {
	family: RegisterFamily,
	size:   Size,
	// high:   bool,
}
Register :: struct {
	using group: RegisterGroup,
	index:       u8,
}
RegisterFamily :: enum {
	Gpr,
	X87, // ST(0)-ST(7)
	Mmx, // MM0-MM7
	AVX, // [XYZ]MM0-31
	AVX_Opmask, // k0-k7
	Segment, // ES, CS, SS, DS, FS, GS
	Bound, // BND0-BND3
	Debug, // DR0-DR7
	Control, // CR0-CR8
	Flags, // EFLAGS/RFLAGS
	IP, // EIP/RIP
}
Gpr :: enum {
	Invalid,
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
X87 :: enum {
	ST0,
	ST1,
	ST2,
	ST3,
	ST4,
	ST5,
	ST6,
	ST7,
}
MM :: enum {
	MM0,
	MM1,
	MM2,
	MM3,
	MM4,
	MM5,
	MM6,
	MM7,
}
XMM :: enum {
	XMM0,
	XMM1,
	XMM2,
	XMM3,
	XMM4,
	XMM5,
	XMM6,
	XMM7,
	XMM8,
	XMM9,
	XMM10,
	XMM11,
	XMM12,
	XMM13,
	XMM14,
	XMM15,
}
YMM :: enum {
	YMM0,
	YMM1,
	YMM2,
	YMM3,
	YMM4,
	YMM5,
	YMM6,
	YMM7,
	YMM8,
	YMM9,
	YMM10,
	YMM11,
	YMM12,
	YMM13,
	YMM14,
	YMM15,
}
ZMM :: enum {
	ZMM0,
	ZMM1,
	ZMM2,
	ZMM3,
	ZMM4,
	ZMM5,
	ZMM6,
	ZMM7,
	ZMM8,
	ZMM9,
	ZMM10,
	ZMM11,
	ZMM12,
	ZMM13,
	ZMM14,
	ZMM15,
}
//AVX_Opmask
K :: enum {
	K0,
	K1,
	K2,
	K3,
	K4,
	K5,
	K6,
	K7,
}
//Debug
DR :: enum {
	DR0,
	DR1,
	DR2,
	DR3,
	DR4,
	DR5,
	DR6,
	DR7,
}
// Control
CR :: enum {
	CR0,
	CR1,
	CR2,
	CR3,
	CR4,
	CR5,
	CR6,
	CR7,
	CR8,
}
//Segment
Segment :: enum {
	ES,
	CS,
	SS,
	DS,
	FS,
	GS,
}
//Flags
Flags :: enum {
	Unsized,
	Flags16,
	EFlags,
	RFlags,
}
// InstructionPointer
IP :: enum {
	IP16,
	EIP,
	RIP,
}
