package ojitsu

//odinfmt: xdisable
movs: map[InstrDesc]ISA_Instruction = {
	//
	// GPR - IMM OPS
	//
	0x0 = ISA_Instruction{
		instr_str = "MOV r/m16, imm16",
		opcode_str = "C7 /0 iw",
		arch = {.x64, .x86},
		opcodes = {0xC7},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_16}, {kind = .Imm, mod_rm = .Reg_0, size = .Bits_16}},
	},
	0x0 = ISA_Instruction{
		instr_str = "MOV r/m32, imm32",
		opcode_str = "C7 /0 id",
		arch = {.x64, .x86},
		opcodes = {0xC7},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_32}, {kind = .Imm, mod_rm = .Reg_0, size = .Bits_32}},
	},
	0x0 = ISA_Instruction{
		instr_str = "REX.W + C7 /0 id",
		opcode_str = "MOV r/m64, imm32",
		arch = {.x64},
		rex = {.REX_Enable, .REX_W},
		opcodes = {0xC7},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_64}, {kind = .Imm, mod_rm = .Reg_0, size = .Bits_32}},
	}, // Move imm32 sign extended to 64-bits to r/m64.
	//
	// REG-REG OPS
	//
	0x0 = ISA_Instruction{
		instr_str = "89 /r",
		opcode_str = "MOV r/m16,r16",
		arch = {.x64, .x86},
		opcodes = {0x89},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_16}, {kind = .Gpr, mod_rm = .Reg, size = .Bits_16}},
	},
	0x0 = ISA_Instruction{
		instr_str = "89 /r",
		opcode_str = "MOV r/m32,r32",
		arch = {.x64, .x86},
		opcodes = {0x89},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_32}, {kind = .Gpr, mod_rm = .Reg, size = .Bits_32}},
	},
	0x0 = ISA_Instruction{
		instr_str = "REX.W + 89 /r",
		opcode_str = "MOV r/m64,r64",
		arch = {.x64},
		rex = {.REX_Enable, .REX_W},
		opcodes = {0x89},
		operands = {{kind = .Gpr, mod_rm = .RM, size = .Bits_64}, {kind = .Gpr, mod_rm = .Reg, size = .Bits_64}},
	},
}
//odinfmt: enable
