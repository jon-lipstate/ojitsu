package ojitsu
import "core:fmt"
SpecialFlags :: bit_set[SpecialFlag]
SpecialFlag :: enum {
	SignExtend,
	ZeroExtend,
	TakeLower16,
	SegmentRegister,
	ImplicitDest,
	ImplicitSrc,
}
//Questions: 
// How to encode the m16 imm8 etc?
// how to encode explicit destinations (EAX), or classes (SRegs)?
// instruction lookup:
// 1. find opcode group (.mov) by indexing into top level array -> [<50]Opcodes
// 2. filter by encoding -> [~5]Opcodes
// 3. Filter for special flags & special registers, atypical calls (eg implicit dest w/ single arg on dyadic call) (.ZeroExtend, .SignExtend, segment) -> [2?]Opcodes
// 4. filter by size -> [2?]Opcodes
// 5. filter by arch -> 1? opcode

OpcodeFilter :: struct {
	encoding:      Encoding,
	arg_size:      []u32, // 8 = 0b1000 || 1<<4 -- use masks to test for size, 1<<31 for optional?
	arch:          u8, // 1:x86, 2:x64, 4:x86_64
	special_flags: u32,
}
Arch :: enum {
	x86,
	x64,
	Any,
}

reg_to_flag :: proc(gp: GeneralPurpose) -> OperandFlag {
	spall.event_scope(&ctx, &buffer, #procedure)
	#partial switch gp {
	case .AL, .AH, .BL, .BH, .CL, .CH, .DH, .DIL, .SIL, .SPL:
		return .r8
	case .AX, .BX, .CX, .DX:
		return .r16
	case .EAX, .EBX, .ECX, .EDX, .EBP, .EDI, .ESI, .ESP:
		return .r32
	case .RAX, .RBX, .RCX, .RDX, .RSP, .RDI, .RSI, .RBP, .R0, .R1, .R2, .R3, .R4, .R5, .R6, .R7, .R8, .R9, .R10, .R11, .R12, .R13, .R14, .R15:
		return .r64
	case:
		fmt.println(gp)
		panic("missing")
	}
}
imm_to_flag :: proc(imm: Imm) -> OperandFlag {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch i in imm {
	case (u8):
		return .imm8
	case (u16):
		return .imm16
	case (u32):
		return .imm32
	case (u64):
		return .imm64
	}
	return .Invalid
}
get_operand_flag :: proc(arg: Operand) -> OperandFlag {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch a in arg {
	case (GeneralPurpose):
		return reg_to_flag(a)
	case (Reg):
		return reg_to_flag(a.reg)
	case (Mem):
		panic("not impl")
	case (Imm):
		return imm_to_flag(a)
	case (Label):
		panic("invalid path..?")
	}
	return .Invalid
}
get_encoding :: proc(args: ..OperandFlag) -> Encoding {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch len(args) {
	case 0:
		return .ZO
	case 1:
		#partial switch args[0] {
		case .moffs8, .moffs16, .moffs32, .moffs64:
			panic("insufficient info")
		// return .TD // .FD
		}
	case 2:
	case:
		panic("Not impl")
	}
	return .Invalid
}
InstrDesc :: distinct u64
get_descriptor :: proc(arch: Arch, operands: ..OperandFlag) -> InstrDesc { 	//special: SpecialFlags,
	spall.event_scope(&ctx, &buffer, #procedure)
	desc: InstrDesc = 0
	// use 12 bit spaces for each operand, starting at zero
	for op, i in operands {
		assert(i < 6)
		class := get_operand_class(op)
		class_val: u8 = 0
		switch class {
		case .sreg:
			class_val = 0
		case .reg:
			class_val = 1
		case .mem:
			class_val = 2
		case .reg_mem:
			class_val = 3
		// panic("todo remove this, wont work with map...")
		case .imm:
			class_val = 4
		case .moffs:
			class_val = 5
		}
		desc |= 1 << (u8(i) * 12 + class_val)
		size := get_operand_size(op)
		size_val: u8 = 0
		switch size {
		case .byte:
			size_val = 0
		case .word:
			size_val = 1
		case .dword:
			size_val = 2
		case .qword:
			size_val = 3
		}
		desc |= 1 << (u8(i) * 12 + 5 + size_val) // +5 moves above desc
	}
	return desc
}
@(link_section = ".rdata")
MOV_ARR := []Opcode{{{0x8A, 0, 0}, .Any, {.r8, .m8}, {.REX_Opt}, {.mod_rm}}, {{0x8A, 0, 0}, .Any, {.r8, .m8}, {.REX_Opt}, {.mod_rm}}}
rets: map[InstrDesc]Opcode = {}
movs: map[InstrDesc]Opcode = {
	0x22024 = {{0x88, 0, 0}, .Any, {.m8, .r8}, {.REX_Opt}, {.mod_rm}},
	0x24022 = {{0x8A, 0, 0}, .Any, {.r8, .m8}, {.REX_Opt}, {.mod_rm}},
	0x22022 = {{0x88, 0, 0}, .Any, {.r8, .r8}, {.REX_Opt}, {.mod_rm}},
	0x20022 = {{0xA0, 0, 0}, .Any, {.al, .moffs8}, {.REX_Opt, .REX_W}, nil}, // implicit AL dest
	0x22020 = {{0xA2, 0, 0}, .Any, {.moffs8, .al}, {.REX_Opt, .REX_W}, nil}, // implicit AL src
	0x30022 = {{0xB0, 0, 0}, .Any, {.r8, .imm8}, {.REX_Opt}, {.rb, .ib}},
	0x30024 = {{0xC6, 0, 0}, .Any, {.m8, .imm8}, {.REX_Opt}, {.digit_0, .ib}},
	//
	0x42044 = {{0x89, 0, 0}, .Any, {.m16, .r16}, nil, {.mod_rm}}, // need 66 prefx??
	0x42042 = {{0x89, 0, 0}, .Any, {.r16, .r16}, nil, {.mod_rm}}, // need 66 prefx??
	0x44042 = {{0x8B, 0, 0}, .Any, {.r16, .m16}, nil, {.mod_rm}}, // need 66 prefx??
	0x101042 = {{0x8C, 0, 0}, .Any, {.r16, .sreg}, nil, {.mod_rm}},
	0x101044 = {{0x8C, 0, 0}, .Any, {.m16, .sreg}, nil, {.mod_rm}},
	0x44101 = {{0x8E, 0, 0}, .Any, {.sreg, .m16}, nil, {.mod_rm}},
	0x42101 = {{0x8E, 0, 0}, .Any, {.sreg, .r16}, nil, {.mod_rm}},
	0x60042 = {{0xA1, 0, 0}, .Any, {.ax, .moffs16}, nil, nil}, // implicit AX dest
	0x42060 = {{0xA3, 0, 0}, .Any, {.moffs16, .ax}, nil, nil}, // implicit AX src
	0x50042 = {{0xB8, 0, 0}, .Any, {.r16, .imm16}, nil, {.rw, .iw}},
	0x50044 = {{0xC7, 0, 0}, .Any, {.m16, .imm16}, nil, {.digit_0, .iw}},
	//
	0x82084 = {{0x89, 0, 0}, .Any, {.m32, .r32}, nil, {.mod_rm}},
	0x82082 = {{0x89, 0, 0}, .Any, {.r32, .r32}, nil, {.mod_rm}},
	0x84082 = {{0x8B, 0, 0}, .Any, {.r32, .m32}, nil, {.mod_rm}},
	0x101082 = {{0x8C, 0, 0}, .Any, {.r32, .sreg}, nil, {.mod_rm}}, // r32 Dup from line above
	0xA0082 = {{0xA1, 0, 0}, .Any, {.eax, .moffs32}, nil, nil}, // implicit EAX dest
	0x820A0 = {{0xA3, 0, 0}, .Any, {.moffs32, .eax}, nil, nil}, // implicit EAX src
	0x90082 = {{0xB8, 0, 0}, .Any, {.r32, .imm32}, nil, {.rd, .id}},
	0x90084 = {{0xC7, 0, 0}, .Any, {.m32, .imm32}, nil, {.digit_0, .id}},
	//
	0x102104 = {{0x89, 0, 0}, .x64, {.m64, .r64}, {.REX_Enable, .REX_W}, {.mod_rm}}, // Expand RM to M,R
	0x102102 = {{0x89, 0, 0}, .x64, {.r64, .r64}, {.REX_Enable, .REX_W}, {.mod_rm}},
	0x104102 = {{0x8B, 0, 0}, .x64, {.r64, .m64}, {.REX_Enable, .REX_W}, {.mod_rm}},
	0x101102 = {{0x8C, 0, 0}, .Any, {.r64, .sreg}, {.REX_Enable, .REX_W}, {.mod_rm}},
	0x104101 = {{0x8E, 0, 0}, .Any, {.sreg, .m64}, {.REX_Enable, .REX_W}, {.mod_rm}},
	0x102101 = {{0x8E, 0, 0}, .Any, {.sreg, .r64}, {.REX_Enable, .REX_W}, {.mod_rm}},
	0x120102 = {{0xA1, 0, 0}, .x64, {.rax, .moffs64}, {.REX_Enable, .REX_W}, nil}, // implicit RAX dest
	0x102120 = {{0xA3, 0, 0}, .x64, {.moffs64, .rax}, {.REX_Enable, .REX_W}, nil}, // implicit RAX src
	0x110102 = {{0xB8, 0, 0}, .x64, {.r64, .imm64}, {.REX_Enable, .REX_W}, {.rd, .io}},
	0x90104 = {{0xC7, 0, 0}, .x64, {.m64, .imm32}, {.REX_Enable, .REX_W}, {.digit_0, .id}},
	0x90102 = {{0xC7, 0, 0}, .x64, {.r64, .imm32}, {.REX_Enable, .REX_W}, {.digit_0, .id}},
}

Opcode :: struct {
	code:            [3]u8,
	arch:            Arch,
	operands:        []OperandFlag,
	Prefixes:        Prefixes,
	opcode_encoding: OpcodeEncoding,
	// descriptor needed items:
	// special_flags:   SpecialFlags,
	// encoding:        Encoding, // TODO: remove..?
}
Size :: enum {
	byte  = 8,
	word  = 16,
	dword = 32,
	qword = 64,
	// oword  = 128, // better to do x128, y256, z512 ??
	// doword = 256,
	// qoword = 512,
}
Encoding :: enum {
	Invalid,
	ZO, // ZeroOperand
	I, // Immediate
	MR,
	RM,
	RI,
	MI,
	FD, // fixed dest
	TD,
	OI,
	RMI,
	RVM,
	RVMI,
	RVMR,
	M,
	A,
	B,
	C,
	D,
	E,
	F,
	G,
}
OpcodeEncoding :: bit_set[OpcodeEncodingFlags]
OpcodeEncodingFlags :: enum {
	NP, // not permitted:: 66,F2,F3
	NF2,
	NF3,
	//
	// REX_W,
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
	mod_rm, // ModRM is used
	// A 1-byte (cb), 2-byte (cw), 4-byte (cd), 6-byte (cp), 8-byte (co) or 10-byte (ct) value following the opcode. 
	// This value is used to specify a code offset and possibly a new value for the code segment register.
	cb,
	cw,
	cd,
	cp,
	co,
	ct,
	// Immediate Byte Operand follows opcode & modrm
	db,
	dw,
	dxx, //?
	// A 1-byte (ib), 2-byte (iw), 4-byte (id) or 8-byte (io) immediate operand to the instruction that
	// follows the opcode, ModR/M bytes or scale-indexing bytes. The opcode determines if the operand is a signed
	// value. All words, doublewords, and quadwords are given with the low-order byte first.
	ib,
	iw,
	id,
	io,
	// rx flags: Indicated the lower 3 bits of the opcode byte is used to encode the register operand without a modR/M byte
	// Affects Byte Preceding it.
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
	BND,
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
	REX_Opt,
	REX_Enable, // 64
	REX_W, // 8, 1: 64-bit Operand, 0: Operand size deteOperandned by CS.D
	REX_R, // 4, Extends ModRM Reg (Dest)
	REX_X, // 2, Extends SIB Index
	REX_B, // 1, Extends SIB Base
}

prefix_value := map[Prefix_Flag]u8 {
	.Lock                = 0xF0,
	.BND                 = 0xF2,
	.REPNZ               = 0xF2,
	.REP                 = 0xF3,
	.CS_Override         = 0x2E,
	.SS_Override         = 0x36,
	.DS_Override         = 0x3E,
	.ES_Override         = 0x26,
	.FS_Override         = 0x64,
	.GS_Override         = 0x65,
	.BranchNotTaken      = 0x2E,
	.BranchTaken         = 0x3E,
	.OpSizeOverride      = 0x66,
	.AddressSizeOverride = 0x67,
	.REX_Enable          = 0b0100_0000,
	.REX_W               = 0b1000,
	.REX_R               = 0b0100,
	.REX_X               = 0b0010,
	.REX_B               = 0b0001,
}
//BND prefix is encoded using F2H if the following conditions are true:
// CPUID.(EAX=07H, ECX=0):EBX.MPX[bit 14] is set.
// BNDCFGU.EN and/or IA32_BNDCFGS.EN is set.
// When the F2 prefix precedes a near CALL, a near RET, a near JMP, a short Jcc, or a near Jcc instruction
// (see Appendix E, "Intel Memory Protection Extensions", of the Intel 64 and IA-32 Architectures
// Software Developer's Manual, Volume 1).

OperandClass :: enum {
	sreg,
	reg,
	mem,
	reg_mem, // TODO: REMOVE
	imm,
	moffs,
}
OperandFlag :: enum {
	Invalid,
	rm8,
	rm16,
	rm32,
	rm64,
	m8,
	m16,
	m32,
	m64,
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
get_operand_size :: proc(o: OperandFlag) -> Size {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch o {
	case .al, .r8, .rm8, .imm8, .m8, .moffs8:
		return .byte
	case .ax, .r16, .rm16, .imm16, .moffs16, .m16:
		return .word
	case .eax, .r32, .rm32, .imm32, .moffs32, .m32:
		return .dword
	case .rax, .r64, .rm64, .imm64, .moffs64, .sreg, .m64:
		return .qword
	case .Invalid:
		panic("Got .Invalid Flag")
	case:
		fmt.println("OperandFlag", o)
		panic("missing")
	}
}
get_operand_class :: proc(o: OperandFlag) -> OperandClass {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch o {
	case .imm8, .imm16, .imm32, .imm64:
		return .imm
	case .sreg:
		return .sreg
	case .m8, .m16, .m32, .m64:
		return .mem
	case .r8, .r16, .r32, .r64, .al, .ax, .eax, .rax:
		return .reg
	case .rm8, .rm16, .rm32, .rm64:
		return .reg_mem
	case .moffs8, .moffs16, .moffs32, .moffs64:
		return .moffs
	case .Invalid:
		panic("Got .Invalid Flag")
	case:
		fmt.println("OperandClass", o)
		panic("missing")
	}
}
// TEMP CODE:
TEMP_descriptors :: proc() {
	ids := map[InstrDesc]int{}
	descs := make([]InstrDesc, len(movs))
	row_num := 0
	for k, op in movs {
		sizes := make([]Size, len(op.operands), context.temp_allocator)
		for o, i in op.operands {
			sizes[i] = get_operand_size(o)
		}
		d := get_descriptor(op.arch, ..op.operands)
		fmt.printf("%X\n", d)
		assert(d not_in ids, fmt.tprintf("Row: %v, other:%v", row_num, ids[d]))
		ids[d] = row_num
		descs[row_num] = d
		row_num += 1
	}
	fmt.println("n_rows:", row_num)
}
