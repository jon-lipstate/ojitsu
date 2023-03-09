package ojitsu
import "core:fmt"

// TODO: Custom Allocator; OS ops can be containerized
// 
// .data - alloc var spaces

// Profiling
import spall_ "profiling"
spall :: spall_
ctx := spall.SpallContext{}
buffer := spall.SpallBuffer{}
ENABLE_PROFILING :: true
//
main :: proc() {
	when ENABLE_PROFILING {
		path := "C:/_repos/c/jit/jit.spall"
		ctx = spall.init(path)
		defer (spall.quit(&ctx))
		buffer = spall.buffer_init()
		defer (spall.buffer_quit(&ctx, &buffer))
		spall.event_scope(&ctx, &buffer, #procedure)
	}
	//
	// TEMP_descriptors()
	a := make_assembler()
	main := get_main_proc(&a)
	mov(main, EAX, ECX) // 89C8   mov ax,cx
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	add(main, EAX, EAX)
	ret(main)
	fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)
	// fmt.println("Call Asm: ", fn_ptr(21))
	// fmt.println("eof")
}
// jcc :: #force_inline proc(p: ^Procedure, cc: ConditionCode) {/*coded_jump := `map[ConditionCode]Mnemonic` into correct code*/push_op(p, coded_jump)}
add :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .add, dest, src)}
mov :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .mov, dest, src)}
ret :: #force_inline proc(p: ^Procedure) {push_op(p, .ret)}

make_assembler :: proc(n_procs: int = 1, allocator := context.allocator) -> Asm {
	spall.event_scope(&ctx, &buffer, #procedure)
	a := Asm{}
	a.procs = make([]Procedure, n_procs) // TODO: How to pass for c-allocators..?
	// a.procs[0].buf = make_dynamic_array_len_cap([dynamic]Instruction, 0, 275)
	return a
}
get_main_proc :: proc(a: ^Asm) -> ^Procedure {
	spall.event_scope(&ctx, &buffer, #procedure)
	return &a.procs[0]
}

assemble :: proc(a: ^Asm) -> rawptr {
	spall.event_scope(&ctx, &buffer, #procedure)
	m := get_main_proc(a) // TODO: TEMP ONLY DO MAIN PROC FOR NOW
	tmp := make([]u8, 4096) // TODO: estimate mem size directly from len instructions, direct VAlloc by est / page sizes
	sized_ops := [4]SizedKind{}
	tmpbuf := [4]u8{}
	current_offset := 0
	label_offsets := map[rawptr]int{}
	instructions := m.buf
	for instr in &instructions {
		switch i in instr {
		case (Label):
			label_offsets[&instr] = current_offset // TODO: Verify `&instr` is dangling or not
		case (ArgsInstruction):
			m := i.mnemonic
			args := i.args
			pfx := i.prefixes
			for arg, i in args {
				sized_ops[i] = get_sized_kind(args[i])
			}
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

			// tmpbuf := make([]u8, 4)
			// mem.zero_slice(tmpbuf)
			bytes_written := encode_instruction(op, tmpbuf[:], i)
		// fmt.printf("Written: %X, [%X,%X,%X,%X]\n", bytes_written, tmpbuf[0], tmpbuf[1], tmpbuf[2], tmpbuf[3])
		}
		mem.zero_slice(sized_ops[:])
	}
	return nil
}

encode_instruction :: proc(isa: ^ISA_Instruction, buf: []u8, instr: ArgsInstruction) -> int {
	spall.event_scope(&ctx, &buffer, #procedure)
	bytes_written := 0
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
	spall.event_scope(&ctx, &buffer, #procedure)
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
	spall.event_scope(&ctx, &buffer, #procedure)
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
	spall.event_scope(&ctx, &buffer, #procedure)
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
import "core:mem"
push_op :: proc(p: ^Procedure, m: Mnemonic, args: ..Operand) { 	//, prefixes := Prefixes{}) {
	spall.event_scope(&ctx, &buffer, #procedure)
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
