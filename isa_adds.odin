package ojitsu

//odinfmt: disnable
adds: map[InstrDesc]ISA_Instruction = {
	//
	// FIXED_A - IMM OPS
	//
	0x0 = ISA_Instruction{instr_str = "ADD EAX, imm32", opcode_str = "05 id", arch = {.x64, .x86}, opcodes = {0x05}, operands = {r_eax, {sized_kind = imm32}}},
	0x02 = ISA_Instruction{
		instr_str = "ADD RAX, imm32",
		opcode_str = "05 id",
		arch = {.x64},
		rex = .REX_W,
		opcodes = {0x05},
		operands = {r_rax, {sized_kind = imm32}},
	}, // Add sign-extended imm32 to RAX
	//
	// REG-IMM OPS
	//
	0x0 = ISA_Instruction{
		instr_str = "81 /0 iw",
		opcode_str = "ADD r/m16, imm16",
		arch = {.x64, .x86},
		opcodes = {0x81},
		operands = {{sized_kind = rm16, mod_rm = ModRM_Flag.RM}, {sized_kind = imm16, mod_rm = .Reg_0}},
	}, // NEEDS OP-PREFIX - infer or explicit ??? Also does /0 mean rm is omitted? i would not think so
	0x0 = ISA_Instruction{
		instr_str = "REX.W + 83 /0 ib",
		opcode_str = "ADD r/m64, imm8",
		arch = {.x64},
		rex = .REX_W,
		opcodes = {0x83},
		operands = {{sized_kind = rm64, mod_rm = .RM}, {sized_kind = imm8, mod_rm = .Reg_0}},
	}, //Add imm32 sign-extended to 64-bits to r/m64.
	//
	// REG-REG OPS
	//
	0x0 = ISA_Instruction{
		instr_str = "01 /r",
		opcode_str = "ADD r/m16, r16",
		arch = {.x64, .x86},
		opcodes = {0x01},
		operands = {{sized_kind = rm16, mod_rm = .RM}, {sized_kind = reg16, mod_rm = .Reg}},
	},
	0x82082 = ISA_Instruction{
		instr_str = "01 /r",
		opcode_str = "ADD r/m32, r32",
		arch = {.x64, .x86},
		opcodes = {0x01},
		operands = {{sized_kind = rm32, mod_rm = .RM}, {sized_kind = reg32, mod_rm = .Reg}},
	},
	0x0 = ISA_Instruction{
		instr_str = "REX.W + 01 /r",
		opcode_str = "ADD r/m64, r64",
		rex = .REX_W,
		arch = {.x64},
		opcodes = {0x01},
		operands = {{sized_kind = rm64, mod_rm = .RM}, {sized_kind = reg64, mod_rm = .Reg}},
	},
}

//odinfmt: enable

// 0x0 = ISA_Instruction{
//     instr_str = "ADD AL, imm8",
//     opcode_str = "04 ib",
//     arch = {.x64, .x86},
//     opcodes = {0x04},
//     operands = {{kind = .Reg, size = .Bits_8, fixed_register = .AL}, {kind = .Imm, size = .Bits_8}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD AX, imm16",
//     opcode_str = "05 iw",
//     arch = {.x64, .x86},
//     opcodes = {0x05},
//     operands = {{kind = .Reg, size = .Bits_16, fixed_register = .AX}, {kind = .Imm, size = .Bits_16}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD reg/mem8, imm8 ",
//     opcode_str = "80 /0 ib",
//     arch = {.x64, .x86},
//     legacy = nil,
//     rex = nil,
//     vector = nil,
//     opcodes = {0x80},
//     operands = {{kind = .RegMem, size = .Bits_8}, {kind = .Imm, size = .Bits_8, mod_rm = .Reg_0}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD reg/mem16, imm16 ",
//     opcode_str = "81 /0 iw",
//     arch = {.x64, .x86},
//     legacy = nil,
//     rex = nil,
//     vector = nil,
//     opcodes = {0x81},
//     operands = {{kind = .RegMem, size = .Bits_16}, {kind = .Imm, size = .Bits_16, mod_rm = .Reg_0}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD reg/mem32, imm32",
//     opcode_str = "81 /0 id",
//     arch = {.x64, .x86},
//     legacy = nil,
//     rex = nil,
//     vector = nil,
//     opcodes = {0x81},
//     operands = {{kind = .RegMem, size = .Bits_32}, {kind = .Imm, size = .Bits_32, mod_rm = .Reg_0}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD reg/mem64, imm32",
//     opcode_str = "81 /0 id",
//     arch = {.x64},
//     legacy = nil,
//     rex = {.REX_Enable, .REX_W},
//     vector = nil,
//     opcodes = {0x81},
//     operands = {{kind = .RegMem, size = .Bits_64, mod_rm = .RM}, {kind = .Imm, size = .Bits_32, mod_rm = .Reg_0}},
// },
// 0x0 = ISA_Instruction{
//     instr_str = "ADD reg/mem64, imm32",
//     opcode_str = "81 /0 id",
//     arch = {.x64},
//     legacy = nil,
//     rex = {.REX_Enable, .REX_W},
//     vector = nil,
//     opcodes = {0x81},
//     operands = {{kind = .RegMem, size = .Bits_64, mod_rm = .RM}, {kind = .Imm, size = .Bits_32, mod_rm = .Reg_0}},
// },
