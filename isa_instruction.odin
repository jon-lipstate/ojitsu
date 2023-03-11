package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
Arch :: bit_set[ArchFlag]
ArchFlag :: enum {
	x86,
	x64,
}

Size :: enum u16 {
	Invalid  = 0xFFFF,
	Unsized  = 0,
	Bits_8   = 8,
	Bits_8H  = 8,
	Bits_16  = 16,
	Bits_32  = 32,
	Bits_64  = 64,
	Bits_128 = 128,
	Bits_256 = 256,
	Bits_512 = 512,
}
OperandKind :: enum u8 {
	Invalid,
	BranchDisp,
	SegmentReg,
	Reg,
	Mem,
	Reg_or_Mem,
	Imm,
	Offset,
}
SizedKind :: struct {
	kind: OperandKind,
	size: Size,
}
r_al :: ISA_Operand {
	sized_kind     = reg8,
	fixed_register = .AL,
}
r_ax :: ISA_Operand {
	sized_kind     = reg8,
	fixed_register = .AX,
}
r_eax :: ISA_Operand {
	sized_kind     = reg8,
	fixed_register = .EAX,
}
r_rax :: ISA_Operand {
	sized_kind     = reg8,
	fixed_register = .RAX,
}
reg8 :: SizedKind{.Reg, .Bits_8}
reg16 :: SizedKind{.Reg, .Bits_16}
reg32 :: SizedKind{.Reg, .Bits_32}
reg64 :: SizedKind{.Reg, .Bits_64}
//
rm8 :: SizedKind{.Reg_or_Mem, .Bits_8}
rm16 :: SizedKind{.Reg_or_Mem, .Bits_16}
rm32 :: SizedKind{.Reg_or_Mem, .Bits_32}
rm64 :: SizedKind{.Reg_or_Mem, .Bits_64}
//
imm8 :: SizedKind{.Imm, .Bits_8}
imm16 :: SizedKind{.Imm, .Bits_16}
imm32 :: SizedKind{.Imm, .Bits_32}
imm64 :: SizedKind{.Imm, .Bits_64}

Symbol :: struct {
	offset: u32,
	len:    u16,
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

ISA_Instruction :: struct {
	arch:          Arch, // x86 | x64
	legacy:        LegacyPrefixes, // Legacy Group 1-4
	rex:           REX, //  REX
	vector:        VectorPrefix, // eg: EVEX,XOP,VEX.LZ.66.0F38.W1
	opcodes:       []u8,
	opcode_append: u8, // +i, +rx
	//
	operands:      []ISA_Operand,
	extensions:    []Extensions, // AVX SSE etc
	// TODO: TEMP - Delete:
	instr_str:     string, // raw str for cross checking
	opcode_str:    string,
}
ISA_Operand :: struct {
	using sized_kind: SizedKind,
	mod_rm:           ModRM_Flag,
	fixed_register:   Gpr, // E.g. Targets RAX Only // TODO: .ANY_A or bit_set[allowed]
}
ModRM_Flag :: enum {
	None,
	Reg,
	RM,
	// /0 to /7:
	Reg_0,
	Reg_1,
	Reg_2,
	Reg_3,
	Reg_4,
	Reg_5,
	Reg_6,
	Reg_7,
}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

Extensions :: bit_set[ExtensionFlag]
ExtensionFlag :: enum {
	_3DNOW,
	_3DNOW2,
	ADX,
	AESNI,
	AMX_TILE,
	AMX_BF16,
	AMX_INT8,
	AVX,
	AVX_VNNI,
	AVX2,
	AVX512_4FMAPS,
	AVX512_4VNNIW,
	AVX512_BF16,
	AVX512_BITALG,
	AVX512_BW,
	AVX512_CDI,
	AVX512_DQ,
	AVX512_ERI,
	AVX512_F,
	AVX512_FP16,
	AVX512_IFMA,
	AVX512_PFI,
	AVX512_VBMI,
	AVX512_VBMI2,
	AVX512_VNNI,
	AVX512_VL,
	AVX512_VP2INTERSECT,
	AVX512_VPOPCNTDQ,
	BMI,
	BMI2,
	CET_IBT,
	CET_SS,
	CLDEMOTE,
	CLFLUSH,
	CLFLUSHOPT,
	CLWB,
	CLZERO,
	CMOV,
	CMPXCHG8B,
	CMPXCHG16B,
	ENCLV,
	ENQCMD,
	F16C,
	FMA,
	FMA4,
	FSGSBASE,
	FXSR,
	GEODE,
	HLE,
	HRESET,
	GFNI,
	I486,
	LAHFSAHF,
	LWP,
	LZCNT,
	MCOMMIT,
	MMX,
	MMX2,
	MONITOR,
	MONITORX,
	MOVBE,
	MOVDIR64B,
	MOVDIRI,
	MPX,
	MSR,
	OSPKE,
	PCLMULQDQ,
	PCOMMIT,
	PCONFIG,
	POPCNT,
	PREFETCHW,
	PREFETCHWT1,
	PTWRITE,
	RDPID,
	RDPRU,
	RDRAND,
	RDSEED,
	RDTSC,
	RDTSCP,
	RTM,
	SEAM,
	SERIALIZE,
	SHA,
	SKINIT,
	SMAP,
	SMX,
	SNP,
	SSE,
	SSE2,
	SSE3,
	SSE4_1,
	SSE4_2,
	SSE4A,
	SSSE3,
	SVM,
	TBM,
	TSX,
	TSXLDTRK,
	UINTR,
	VAES,
	VPCLMULQDQ,
	VMX,
	WAITPKG,
	WBNOINVD,
	XOP,
	XSAVE,
	XSAVEC,
	XSAVEOPT,
	XSAVES,
}
