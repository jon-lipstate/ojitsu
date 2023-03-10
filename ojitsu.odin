package ojitsu
import "core:fmt"
import "core:mem"
//
import _spall "core:prof/spall"
spall :: _spall
spall_ctx := spall.Context{}
spall_buffer := spall.Buffer{}
//
main :: proc() {
	// test_constant(42)
	// Profiling Setup:
	spall_ctx = spall.context_create("jit_dump.spall")
	buffer_backing := make([]u8, 1024)
	spall_buffer = spall.buffer_create(buffer_backing)
	defer spall.context_destroy(&spall_ctx)
	defer spall.buffer_destroy(&spall_ctx, &spall_buffer)
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)

	a := make_assembler()
	defer free_os_memory(a.buf)
	main := get_main_proc(&a)
	mov(main, EAX, ECX) // 89C8   mov ax,cx
	add(main, EAX, EAX)
	ret(main)
	fn_ptr := transmute(proc(x: i32) -> i32)assemble(&a) // TODO: accessing other procs
	fmt.println("Call Asm: ", fn_ptr(21))
}
// runtime encode:
// rt := Procedure{}
// mov(&rt, EAX, ECX)
// tmp := make([^]u8, 16)
// n_bytes := encode(&rt.buf[0], tmp)

make_assembler :: proc(n_procs: int = 1, allocator := context.allocator) -> Asm {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	a := Asm{}
	a.procs = make([]Procedure, n_procs) // TODO: How to pass for c-allocators..?
	// a.procs[0].buf = make_dynamic_array_len_cap([dynamic]Instruction, 0, 500)
	a.buf = get_os_memory()
	return a
}
get_main_proc :: proc(a: ^Asm) -> ^Procedure {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	return &a.procs[0] // primary proc at 0 by convention
}

assemble :: proc(a: ^Asm) -> rawptr {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	m := get_main_proc(a) // TODO: TEMP ONLY DO MAIN PROC FOR NOW
	sized_ops := [8]SizedKind{}
	instructions := m.buf
	for instr in &instructions {
		switch ins in instr {
		case (Label):
			panic("not impl")
		case (ArgsInstruction):
			m := ins.mnemonic
			args := ins.args
			pfx := ins.prefixes
			for arg, i in args {sized_ops[i] = get_sized_kind(args[i])}
			d := get_descriptor({.x86, .x64}, ..sized_ops[:len(args)])
			// fmt.printf("0x%X, %v\n", d, m)
			lut := ISA_LUT[m]
			assert(lut != nil)
			op := &lut[d]
			if d not_in lut {
				panic(fmt.tprintf("No matching instruction for `%v %v %v`\n", m, args[0], args[1]))
			}
			// fmt.println(op)
			// fmt.printf("Instr: %X\n", op.code[0])
			a.bytes_written += encode_instruction(op, &a.buf[a.bytes_written], ins)
		// fmt.printf("Written: %X, [%X,%X,%X,%X]\n", bytes_written, tmpbuf[0], tmpbuf[1], tmpbuf[2], tmpbuf[3])
		}
		mem.zero_slice(sized_ops[:])
	}
	//Show instruction stream:
	when false {
		fmt.printf("Instruction-Stream: [")
		for i: uint = 0; i < a.bytes_written; i += 1 {
			fmt.printf("%X", a.buf[i])
			if i < a.bytes_written - 1 do fmt.printf(" ")
		}
		fmt.printf("]\n")
	}
	protect_os_memory(a.buf)
	return a.buf
}

encode :: proc(instr: ^Instruction, buf: [^]u8) -> uint {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)

	return 0
}
encode_instruction :: proc(isa: ^ISA_Instruction, buf: [^]u8, instr: ArgsInstruction) -> uint {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	bytes_written: uint = 0
	if isa.legacy != nil {
		//Group 1 legacy
		if .Lock in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.Lock];bytes_written += 1}
		if .REPNZ in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.REPNZ];bytes_written += 1}
		if .REP in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.REP];bytes_written += 1}
		if .BND in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.BND];bytes_written += 1} 	// todo: test for rules (pdf pg-525) ?
		//Group 2 legacy
		if .CS_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.CS_Override];bytes_written += 1}
		if .SS_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.SS_Override];bytes_written += 1}
		if .DS_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.DS_Override];bytes_written += 1}
		if .ES_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.ES_Override];bytes_written += 1}
		if .FS_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.FS_Override];bytes_written += 1}
		if .GS_Override in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.GS_Override];bytes_written += 1}
		if .BranchNotTaken in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.BranchNotTaken];bytes_written += 1}
		if .BranchTaken in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.BranchTaken];bytes_written += 1}
		//Group 3 legacy
		if .OpSizeOverride in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.OpSizeOverride];bytes_written += 1}
		//Group 4 legacy
		if .AddressSizeOverride in isa.legacy {buf[bytes_written] = PREFIX_VALUES[.AddressSizeOverride];bytes_written += 1}
	}
	if should_use_rex(..isa.operands) && .REX_Enable in isa.rex {
		rex: u8 = 0b0100_0000
		if .REX_W in isa.rex {rex |= 0b1000}
		if .REX_R in isa.rex {rex |= 0b0100}
		if .REX_X in isa.rex {rex |= 0b0010}
		if .REX_B in isa.rex {rex |= 0b0001}
		buf[bytes_written] = rex;bytes_written += 1
	}
	// Write Actual Opcode:
	for b in isa.opcodes {
		buf[bytes_written] = b;bytes_written += 1
	}
	buf[bytes_written - 1] |= isa.opcode_append
	if ok, mod_rm := encode_mod_rm(isa, instr); ok {
		buf[bytes_written] = mod_rm;bytes_written += 1
	}
	return bytes_written
}
encode_mod_rm :: proc(isa: ^ISA_Instruction, ins: ArgsInstruction) -> (bool, u8) {
	// TODO: Refactor for non-MOD=3 intsructions
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	mod_rm: u8 = 0x0
	if len(isa.operands) == 0 {return false, 0x0}
	// technically this is wasteful for ops > 2...
	for isa_op, idx in isa.operands {
		op := ins.args[idx]
		modify_mod_rm(&mod_rm, isa_op, op)
	}
	// TODO: hard coded reg-reg for now, need full gamut
	mod_rm |= u8(0b11) << 6

	return true, mod_rm

	//	      mod	         reg                  rm
	// return u8(mod) << 6 | u8(dest_byte) << 3 | u8(src_byte)
}
modify_mod_rm :: proc(mod_rm: ^u8, isa_op: ISA_Operand, op: Operand) {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	reg, is_reg := op.(Reg)
	#partial switch isa_op.mod_rm {
	case .Reg:
		v := MOD_RM_LUT[reg.reg]
		mod_rm^ |= u8(v) << 3
	case .RM:
		if is_reg {mod_rm^ |= u8(MOD_RM_LUT[reg.reg]) << 0} else {panic("not impl")}
	case .Reg_0:
		mod_rm^ |= u8(0x0) << 3
	case .Reg_1:
		mod_rm^ |= u8(0x1) << 3
	case .Reg_2:
		mod_rm^ |= u8(0x2) << 3
	case .Reg_3:
		mod_rm^ |= u8(0x3) << 3
	case .Reg_4:
		mod_rm^ |= u8(0x4) << 3
	case .Reg_5:
		mod_rm^ |= u8(0x5) << 3
	case .Reg_6:
		mod_rm^ |= u8(0x6) << 3
	case .Reg_7:
		mod_rm^ |= u8(0x7) << 3
	}
}
should_use_rex :: proc(operands: ..ISA_Operand) -> bool {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	for o in operands {if o.size == .Bits_64 {return true}}
	return false
}
Mnemonic :: enum {
	mov,
	add,
	ret,
	// call,
	// cmp,
	// jne,
}
// TODO: Prefixes confuses final varag - find resolution
push_op :: proc(p: ^Procedure, m: Mnemonic, args: ..Operand) { 	//, prefixes := Prefixes{}) {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	append(&p.buf, ArgsInstruction{m, {}, mem.clone_slice(args)})
}

Instruction :: union {
	Label, // TODO: make a .Label mneumonic and drop the union?? How to give user handle to it, instruction ptr?
	ArgsInstruction,
}
ArgsInstruction :: struct {
	mnemonic: Mnemonic,
	prefixes: LegacyPrefixes,
	args:     []Operand,
}
