package ojitsu
//odinfmt: disnable
ret_near: map[InstrDesc]ISA_Instruction = {
	0x0 = ISA_Instruction{instr_str = "RET", opcode_str = "C3", arch = {.x64, .x86}, opcodes = {0xC3}}, // Near
	0x1 = ISA_Instruction{instr_str = "RET", opcode_str = "C2", arch = {.x64, .x86}, opcodes = {0xC3}, operands = {{kind = .Imm, size = .Bits_16}}}, // Near
}
ret_far: map[InstrDesc]ISA_Instruction = {
	0x0 = ISA_Instruction{instr_str = "RET", opcode_str = "C3", arch = {.x64, .x86}, opcodes = {0xC3}}, // Far
	0x1 = ISA_Instruction{instr_str = "RET", opcode_str = "CA", arch = {.x64, .x86}, opcodes = {0xC3}, operands = {{kind = .Imm, size = .Bits_16}}}, // Far
}
//odinfmt: enable
