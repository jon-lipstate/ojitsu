package ojitsu
// TODO: User? Flags for Zero & Sign Extend!
UserFlag :: enum {
	SignExtend,
	ZeroExtend,
	TakeLower16,
}
//Questions: 
// How to encode the m16 imm8 etc?
// how to encode explicit destinations (EAX), or classes (SRegs)?

movs: []Opcode = {
	{{0x0, 0x0, 0x88}, nil, {.mod_rm}, .MR, {{.rm8, .r8}}},
	{{0x0, 0x0, 0x88}, {.REX_Enable}, {.mod_rm, .REX_W}, .MR, {{.rm8, .r8}}},
}
// MOV r16/r32/m16, Sreg  Move zero extended 16-bit segment register to r16/r32/m16.

Opcode :: struct {
	code:            [3]u8,
	Prefixes:        Prefixes,
	opcode_encoding: OpcodeEncoding,
	encoding:        Encoding,
	operands:        []OperandFlags,
}
Size :: enum {
	byte   = 8,
	word   = 16,
	dword  = 32,
	qword  = 64,
	oword  = 128, // better to do x128, y256, z512 ??
	doword = 256,
	qoword = 512,
}
Encoding :: enum {
	ZO, // ZeroOperand
	I, // Immediate
	MR,
	RM,
	RI,
	MI,
	FD, // fixed dest
	TD,
	OI,
}
OpcodeEncoding :: bit_set[OpcodeEncodingFlags]
OpcodeEncodingFlags :: enum {
	NP, // not permitted:: 66,F2,F3
	NF2,
	NF3,
	//
	REX_W,
	// A digit between 0 and 7 indicates that the ModR/M byte of the instruction uses only the r/m (register or memory) operand.
	// The reg field contains the digit that provides an extension to the instruction's opcode.
	digit_0,
	digit_1,
	digit_2,
	digit_3,
	digit_4,
	digit_5,
	digit_6,
	digit_7,
	// /r
	mod_rm, // ModRM: uses reg and RM
	// A 1-byte (cb), 2-byte (cw), 4-byte (cd), 6-byte (cp), 8-byte (co) or 10-byte (ct) value following the opcode. 
	// This value is used to specify a code offset and possibly a new value for the code segment register.
	cb,
	cw,
	cd,
	cp,
	co,
	ct,
	// A 1-byte (ib), 2-byte (iw), 4-byte (id) or 8-byte (io) immediate operand to the instruction that
	// follows the opcode, ModR/M bytes or scale-indexing bytes. The opcode determines if the operand is a signed
	// value. All words, doublewords, and quadwords are given with the low-order byte first.
	ib,
	iw,
	id,
	io,
	// rx flags: Indicated the lower 3 bits of the opcode byte is used to encode the register operand without a modR/M byte
	rb,
	rw,
	rd,
	ro,
	// +i is added to the hexadecimal byte given at the left of the plus sign to form a single opcode byte.
	i0,
	i1,
	i2,
	i3,
	i4,
	i5,
	i6,
	i7,
}
// TODO: Map to lookup the actual prefix value, and precedence maybe
Prefixes :: bit_set[Prefix_Flag]
Prefix_Flag :: enum {
	// Group 1:
	Lock,
	BND, // TODO: collides with repne
	REPNZ, // Alias: REPNZ. Repeat Not Zero; Applies to String & IO, Mandatory for some
	REP, // Alias: REPE/REPZ. Repeat
	// Group 2:
	CS_Override,
	SS_Override,
	DS_Override,
	ES_Override,
	FS_Override,
	GS_Override,
	BranchNotTaken, // Used with Jump on Conditions (eg @cold)
	BranchTaken, // Used with JCC
	// Group 3:
	OpSizeOverride, // swap between 16-32 bit ops, flag flips to non-default size
	// Group 4:
	AddressSizeOverride, // swap between 16-32 bit addrs, flag flips to non-default size
	//REX
	// Ref ISR-V2 Fig 2-6
	REX_Enable, // 64
	REX_W, // 8, 1: 64-bit Operand, 0: Operand size deteOperandned by CS.D
	REX_R, // 4, Extends ModRM Reg (Dest)
	REX_X, // 2, Extends SIB Index
	REX_B, // 1, Extends SIB Base
}
// Prefix_Flag :: enum {
// 	// Group 1:
// 	Lock                = 0xF0,
// 	BND                 = 0xF2,
// 	REPNZ               = 0xF2,
// 	REP                 = 0xF3,
// 	// Group 2:
// 	CS_Override         = 0x2E,
// 	SS_Override         = 0x36,
// 	DS_Override         = 0x3E,
// 	ES_Override         = 0x26,
// 	FS_Override         = 0x64,
// 	GS_Override         = 0x65,
// 	BranchNotTaken      = 0x2E, // Used with Jump on Conditions (eg @cold)
// 	BranchTaken         = 0x3E, // Used with JCC
// 	// Group 3:
// 	OpSizeOverride      = 0x66, // swap between 16-32 bit ops, flag flips to non-default size
// 	// Group 4:
// 	AddressSizeOverride = 0x67, // swap between 16-32 bit addrs, flag flips to non-default size
// 	//REX
// 	// Ref ISR-V2 Fig 2-6
// 	REX_Enable          = 0b0100_0000, // 64
// 	REX_W               = 0b1000, // 8, 1: 64-bit Operand, 0: Operand size deteOperandned by CS.D
// 	REX_R               = 0b0100, // 4, Extends ModRM Reg (Dest)
// 	REX_X               = 0b0010, // 2, Extends SIB Index
// 	REX_B               = 0b0001, // 1, Extends SIB Base
// }
//BND prefix is encoded using F2H if the following conditions are true:
// CPUID.(EAX=07H, ECX=0):EBX.MPX[bit 14] is set.
// BNDCFGU.EN and/or IA32_BNDCFGS.EN is set.
// When the F2 prefix precedes a near CALL, a near RET, a near JMP, a short Jcc, or a near Jcc instruction
// (see Appendix E, "Intel Memory Protection Extensions", of the Intel 64 and IA-32 Architectures
// Software Developer's Manual, Volume 1).


InstrOperand :: struct {
	allowed: OperandFlags,
}

OperandFlags :: bit_set[OperandFlag]
OperandFlag :: enum {
	rm8,
	rm16,
	rm32,
	rm64,
	r8,
	r16,
	r32,
	r64,
	sreg,
	moffs8,
	moffs16,
	moffs32,
	moffs64,
	al,
	ax,
	eax,
	rax,
	imm8,
	imm16,
	imm32,
	imm64,
}
