package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
Arch :: bit_set[ArchFlag]
ArchFlag :: enum {
	x86,
	x64,
}
Size :: enum {
	Invalid  = 0,
	Bits_8   = 8,
	Bits_16  = 16,
	Bits_32  = 32,
	Bits_64  = 64,
	Bits_128 = 128,
	Bits_256 = 256,
	Bits_512 = 512,
}
OperandKind :: enum {
	Invalid,
	SegmentReg,
	Reg,
	Mem,
	RegMem,
	Imm,
	Offset,
}
SizedKind :: struct {
	kind: OperandKind,
	size: Size,
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
Instruction_ISR :: struct {
	arch:          Arch, // x86 | x64
	legacy:        LegacyPrefixes, // Legacy Group 1-4
	rex:           REX, //  REX
	vector:        VectorPrefix, // eg: EVEX,XOP,VEX.LZ.66.0F38.W1
	opcode:        u8,
	opcode_append: u8, // +i, +rx
	//
	operands:      []Operand_ISR,
	// TODO: TEMP - Delete:
	instr_str:     string,
	opcode_str:    string,
}
Operand_ISR :: struct {
	kind:           OperandKind,
	size:           Size,
	mod_rm:         ModRM_Flag,
	fixed_register: GeneralPurpose, // E.g. Targets RAX Only // TODO: Register:: union {} for XMMs
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
