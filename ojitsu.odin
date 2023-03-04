package ojitsu
import "core:fmt"

// TODO: Custom Allocator; OS ops can be containerized

// .data - alloc var spaces

// Profiling
import spall "profiling"
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
	mov(main, .AX, .CX)
	add(main, .RAX, .RAX)
	ret(main)
	fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)
}
add :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .add, dest, src)}
mov :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .mov, dest, src)}
ret :: #force_inline proc(p: ^Procedure) {push_op(p, .ret)}

make_assembler :: proc(n_procs: int = 1, allocator := context.allocator) -> Asm {
	a := Asm{}
	a.procs = make([]Procedure, n_procs) // TODO: How to pass for c-allocators..?
	return a
}
get_main_proc :: proc(a: ^Asm) -> ^Procedure {
	return &a.procs[0]
}
// If `nil` is passed for the label, one is made; inserts at the current address.
//
// Unbound labels (for use with forward calls) may be produced with `l:=Label{}`
insert_label :: proc(a: ^Asm, l: ^Label) -> ^Label {
	panic("no-impl")
}
assemble :: proc(a: ^Asm) -> rawptr {
	m := get_main_proc(a) // TODO: TEMP ONLY DO MAIN PROC FOR NOW
	tmp := make([]u8, 4096) // TODO: estimate mem size directly from len instructions, direct VAlloc by est / page sizes

	current_offset := 0
	label_offsets := map[rawptr]int{}
	instructions := m.buf
	for instr in &instructions {
		fmt.println(instr)
		switch i in instr {
		case (Label):
			label_offsets[&instr] = current_offset // TODO: Verify `&instr` is dangling or not
		case (ArgsInstruction):
			m := i.mneumnoic
			args := i.args
			pfx := i.prefixes
			if m != .mov do continue
			o0 := get_operand_flag(args[0])
			o1 := get_operand_flag(args[1])
			fmt.println(m)
			fmt.println(args[0], args[1])
			fmt.println(o0, o1)
			d := get_descriptor(.Any, o0, o1)
			fmt.printf("0x%X\n", d)
			op := movs[d]
			assert(d in movs, "d not in movs")
			fmt.println(op)
		// 
		}

	}
	return nil
}

Mneumnoic :: enum {
	mov,
	add,
	call,
	cmp,
	jne,
	ret,
}
// TODO: Prefixes confuses final varag - find resolution
import "core:mem"
push_op :: proc(p: ^Procedure, m: Mneumnoic, args: ..Operand) { 	//, prefixes := Prefixes{}) {
	append(&p.buf, ArgsInstruction{m, {}, mem.clone_slice(args)})
	fmt.println(len(args), args)
}
push_local :: proc(p: ^Procedure, size: Size) -> Ptr {
	// TODO: must be first - idk return type exactly
	// Stack allocated in shadow storage...?
	panic("NOT-IMPL")
}

Instruction :: union {
	Label, // TODO: make a .Label mneumonic and drop the union?? How to give user handle to it, instruction ptr?
	ArgsInstruction,
}
ArgsInstruction :: struct {
	mneumnoic: Mneumnoic,
	prefixes:  Prefixes,
	args:      []Operand,
}

//[bx+si+0x188] [bx+si-0x7d] [cs:si+0x0]
// Emit as Operand to feed into push_op
// TODO: multiple registers should be supported
address_of :: proc(rm: RegMem) -> Operand {
	return nil
}

// TODO: GeneralPurpose is no longer bit-indexed, need to lookup in a static-map now..?
mod_rm :: proc(mod: u8, src: GeneralPurpose, dst: GeneralPurpose) -> u8 {
	// TODO: lookup indices, fix mod
	//	      mod	         reg            rm
	return u8(mod) << 6 | u8(src) << 3 | u8(dst)
}

ty :: enum {
	fpu,
	mmx,
	xmm,
	sse,
	ymm,
	zmm,
	//
	mib,
	vsib,
	vex,
	evex,
}
