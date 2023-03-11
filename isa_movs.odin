package ojitsu

//odinfmt: xdisable
movs: map[InstrDesc]ISA_Instruction = {
	//
	// GPR - IMM OPS
	//
	0x2     = rm16_imm16,
	0x3     = rm32_imm32,
	0x4     = rm64_imm32, // Move imm32 sign extended to 64-bits to r/m64.
	//
	// RM-REG OPS
	//
	0x5     = rm16_reg16,
	0x82082 = rm32_reg32,
	0x6     = rm64_reg64,
}
//odinfmt: enable
@(private)
rm16_imm16 :: ISA_Instruction {
	instr_str = "MOV r/m16, imm16",
	opcode_str = "C7 /0 iw",
	arch = {.x64, .x86},
	opcodes = {0xC7},
	operands = {{sized_kind = rm16, mod_rm = .RM}, {sized_kind = imm16, mod_rm = .Reg_0}},
}
@(private)
rm32_imm32 :: ISA_Instruction {
	instr_str = "MOV r/m32, imm32",
	opcode_str = "C7 /0 id",
	arch = {.x64, .x86},
	opcodes = {0xC7},
	operands = {{sized_kind = rm32, mod_rm = .RM}, {sized_kind = imm32, mod_rm = .Reg_0}},
}
@(private)
rm64_imm32 :: ISA_Instruction {
	instr_str = "REX.W + C7 /0 id",
	opcode_str = "MOV r/m64, imm32",
	arch = {.x64},
	rex = .REX_W,
	opcodes = {0xC7},
	operands = {{sized_kind = rm64, mod_rm = .RM}, {sized_kind = imm32, mod_rm = .Reg_0}},
}
@(private)
rm16_reg16 :: ISA_Instruction {
	instr_str = "89 /r",
	opcode_str = "MOV r/m16,r16",
	arch = {.x64, .x86},
	opcodes = {0x89},
	operands = {{sized_kind = rm16, mod_rm = .RM}, {sized_kind = reg16, mod_rm = .Reg}},
}
@(private)
rm32_reg32 :: ISA_Instruction {
	instr_str = "89 /r",
	opcode_str = "MOV r/m32,r32",
	arch = {.x64, .x86},
	opcodes = {0x89},
	operands = {{sized_kind = rm32, mod_rm = .RM}, {sized_kind = reg32, mod_rm = .Reg}},
}
@(private)
rm64_reg64 :: ISA_Instruction {
	instr_str = "REX.W + 89 /r",
	opcode_str = "MOV r/m64,r64",
	arch = {.x64},
	rex = .REX_W,
	opcodes = {0x89},
	operands = {{sized_kind = rm64, mod_rm = .RM}, {sized_kind = reg64, mod_rm = .Reg}},
}
