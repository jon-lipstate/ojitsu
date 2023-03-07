package ojitsu
import "core:fmt"

// TODO: Custom Allocator; OS ops can be containerized

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
	mov(main, .EAX, .ECX) // 89C8   mov ax,cx
	add(main, .EAX, .EAX)
	ret(main)
	fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)
}
// jcc :: #force_inline proc(p: ^Procedure, cc: ConditionCode) {/*coded_jump := `map[ConditionCode]Mnemonic` into correct code*/push_op(p, coded_jump)}
add :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .add, dest, src)}
mov :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .mov, dest, src)}
ret :: #force_inline proc(p: ^Procedure) {push_op(p, .ret)}

make_assembler :: proc(n_procs: int = 1, allocator := context.allocator) -> Asm {
	spall.event_scope(&ctx, &buffer, #procedure)
	a := Asm{}
	a.procs = make([]Procedure, n_procs) // TODO: How to pass for c-allocators..?
	return a
}
get_main_proc :: proc(a: ^Asm) -> ^Procedure {
	spall.event_scope(&ctx, &buffer, #procedure)
	return &a.procs[0]
}
// If `nil` is passed for the label, one is made; inserts at the current address.
//
// Unbound labels (for use with forward calls) may be produced with `l:=Label{}`
insert_label :: proc(a: ^Asm, l: ^Label) -> ^Label {
	// spall.event_scope(&ctx, &buffer, #procedure)
	panic("no-impl")
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
		// fmt.println(instr)
		switch i in instr {
		case (Label):
			label_offsets[&instr] = current_offset // TODO: Verify `&instr` is dangling or not
		case (ArgsInstruction):
			m := i.mnemonic
			args := i.args
			pfx := i.prefixes
			if m != .mov do continue
			for arg, i in args {
				sized_ops[i] = get_sized_kind(args[i])
			}
			// fmt.println(m, operand_flags[:len(args)])
			d := get_descriptor({.x86, .x64}, ..sized_ops[:len(args)])
			// fmt.printf("0x%X\n", d)
			op := &movs[d]
			if d not_in movs {
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

encode_instruction :: proc(op: ^Instruction_ISR, buf: []u8, instr: ArgsInstruction) -> int {
	spall.event_scope(&ctx, &buffer, #procedure)
	bytes_written := 0
	if op.legacy != nil {
		//Group 1 legacy
		if .Lock in op.legacy {buf[bytes_written] = PREFIX_VALUES[.Lock];bytes_written += 1}
		if .REPNZ in op.legacy {buf[bytes_written] = PREFIX_VALUES[.REPNZ];bytes_written += 1}
		if .REP in op.legacy {buf[bytes_written] = PREFIX_VALUES[.REP];bytes_written += 1}
		if .BND in op.legacy {buf[bytes_written] = PREFIX_VALUES[.BND];bytes_written += 1} 	// todo: test for rules (pdf pg-525) ?
		//Group 2 legacy
		if .CS_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.CS_Override];bytes_written += 1}
		if .SS_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.SS_Override];bytes_written += 1}
		if .DS_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.DS_Override];bytes_written += 1}
		if .ES_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.ES_Override];bytes_written += 1}
		if .FS_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.FS_Override];bytes_written += 1}
		if .GS_Override in op.legacy {buf[bytes_written] = PREFIX_VALUES[.GS_Override];bytes_written += 1}
		if .BranchNotTaken in op.legacy {buf[bytes_written] = PREFIX_VALUES[.BranchNotTaken];bytes_written += 1}
		if .BranchTaken in op.legacy {buf[bytes_written] = PREFIX_VALUES[.BranchTaken];bytes_written += 1}
		//Group 3 legacy
		if .OpSizeOverride in op.legacy {buf[bytes_written] = PREFIX_VALUES[.OpSizeOverride];bytes_written += 1}
		//Group 4 legacy
		if .AddressSizeOverride in op.legacy {buf[bytes_written] = PREFIX_VALUES[.AddressSizeOverride];bytes_written += 1}
	}
	if should_use_rex(..op.operands) && .REX_Enable in op.rex {
		rex: u8 = 0b0100_0000
		if .REX_W in op.rex {rex |= 0b1000}
		if .REX_R in op.rex {rex |= 0b0100}
		if .REX_X in op.rex {rex |= 0b0010}
		if .REX_B in op.rex {rex |= 0b0001}
		buf[bytes_written] = rex;bytes_written += 1
	}
	// Write Actual Opcode:
	oc_val := op.opcode | op.opcode_append
	buf[bytes_written] = oc_val;bytes_written += 1

	// TODO: re-enable ModRM
	// if .mod_rm in op.opcode_encoding {
	// 	// TODO: do for real
	// 	buf[bytes_written] = encode_mod_rm(0b11, instr.args[0].(GeneralPurpose), instr.args[1].(GeneralPurpose))
	// 	bytes_written += 1
	// } else {
	// 	for arg in instr.args {
	// 		//
	// 	}
	// }

	return bytes_written
}
encode_mod_rm :: proc(mod: u8, src: GeneralPurpose, dst: GeneralPurpose) -> u8 {
	spall.event_scope(&ctx, &buffer, #procedure)
	src_byte := MOD_RM_LUT[src]
	dest_byte := MOD_RM_LUT[dst]
	//	      mod	         reg                  rm
	return u8(mod) << 6 | u8(dest_byte) << 3 | u8(src_byte)
}
should_use_rex :: proc(operands: ..Operand_ISR) -> bool {
	spall.event_scope(&ctx, &buffer, #procedure)
	for o in operands {if o.size == .Bits_64 {return true}}
	return false
}
Mnemonic :: enum {
	mov,
	add,
	call,
	cmp,
	jne,
	ret,
}
// TODO: Prefixes confuses final varag - find resolution
import "core:mem"
push_op :: proc(p: ^Procedure, m: Mnemonic, args: ..Operand) { 	//, prefixes := Prefixes{}) {
	spall.event_scope(&ctx, &buffer, #procedure)
	append(&p.buf, ArgsInstruction{m, {}, mem.clone_slice(args)}) // TODO: Hunt for other VARARGS NOT getting cloned
	// fmt.println(len(args), args)
}
push_local :: proc(p: ^Procedure, size: Size) -> Ptr {
	// spall.event_scope(&ctx, &buffer, #procedure)
	// TODO: must be first - idk return type exactly
	// Stack allocated in shadow storage...?
	panic("NOT-IMPL")
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

//[bx+si+0x188] [bx+si-0x7d] [cs:si+0x0]
// Emit as Operand to feed into push_op
// TODO: multiple registers should be supported
address_of :: proc(rm: RegMem) -> Operand {
	spall.event_scope(&ctx, &buffer, #procedure)
	return nil
}
