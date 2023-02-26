package ojitsu
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
	a := make_assembler()
	main := get_main_proc(&a)
	rax := reg(.RAX) // fn gets bit-size
	rcx := reg(.RCX)
	op_rr(main, .mov, rax, reg(.RCX))
	op_rr(main, .add, rax, rax)
	op_zo(main, .ret)
	fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)


}

// .data:
data :: proc(label: string, idk: any) {}

reg :: proc(r: GeneralPurpose) -> Reg {
	reg: Reg = {r, 0}
	set_register_size(&reg)
	return reg
}
set_register_size :: proc(r: ^Reg) {
	#partial switch r.reg {
	// todo: for reals
	case:
		r.bits = 64
	}
}
make_assembler :: proc(n_procs: int = 1, allocator := context.allocator) -> Asm {
	a := Asm{}
	a.procs = make([]Procedure, n_procs) // TODO: How to pass for c-allocators..?
	return a
}
get_main_proc :: proc(a: ^Asm) -> ^Procedure {
	return &a.procs[0]
}
insert_label :: proc(a: ^Asm) -> ^Label {
	// bidx := lep(a.Procedures)
	// appendp&a.Procedurps, Procedure{})
	// lidx := len(a.labels)
	// append(&a.labels, Labelp&a.Procedures[bidx]})
	// return &a.labels[lidx]
	return nil
}
assemble :: proc(a: ^Asm) -> rawptr {
	m := get_main_proc(a) // TODO: TEMP - only one proc-main
	tmp := make([]u8, 4096) // TODO: estimate mem size directly from len instructions, direct VAlloc by est / page sizes

	current_offset := 0
	label_offsets := map[rawptr]int{}
	instructions := m.buf
	for instr in &instructions {
		switch i in instr {
		case (Label):
			label_offsets[&instr] = current_offset // TODO: Verify `&instr` is dangling or not
		case (ZeroOperandInstruction):
			panic("no impl")
		case (BinaryInstruction):
			panic("no impl")
		}

	}
	return nil
}
// `zax` - mapped to either `eax` or `rax` Z prefix for native size

// ["mov, "W:r64/m64, r64", "MR", "REX.W 89 /r"   , "X64 XRelease"],
// ["mov, "W:r64/m64, id" , "MI", "REX.W C7 /0 id", "X64 XRelease"],
// ["mov, "W:r64, r64/m64", "RM", "REX.W 8B /r"   , "X64"],

InstrLib := map[Mneumnoic][]binstr{}
// TODO: I AM HERE - How to Best Retrieve instructions ??
// NOTE: Intsructions can span Operand-Counts:
// .ret can be ZO or I
// .add can be I (implied binary to AL/AX/EAX) or Binary: MI,MR, RM

binstr :: struct {
	kind:           Encoding, // MR MI RR etc
	size:           DataType,
	valid_prefixes: Prefixes,
	is_mod_rm:      bool,
	opcode:         []u8,
}

DataType :: enum {
	byte   = 8,
	word   = 16,
	dword  = 32,
	qword  = 64,
	oword  = 128, // better to do x128, y256, z512 ??
	doword = 256,
	qoword = 512,
}
// ["add", "X:r64/m64, id"  , "MI", "REX.W 81 /0 id", "X64 _XLock OF=W SF=W ZF=W AF=W PF=W CF=W"],
// ["add", "X:~r64,~r64/m64", "RM", "REX.W 03 /r"   , "X64        OF=W SF=W ZF=W AF=W PF=W CF=W"],
// ["add", "X:~r64/m64,~r64", "MR", "REX.W 01 /r"   , "X64 _XLock OF=W SF=W ZF=W AF=W PF=W CF=W"],


movs := []binstr{{.RR, .qword, {}, true, {0x89}}, {.RI, .qword, {}, true, {0xC7}}}
adds := []binstr{{.RR, .qword, {}, true, {0x03}}, {.RI, .qword, {}, true, {0x81}}}

Mneumnoic :: enum {
	mov,
	add,
	call,
	cmp,
	jne,
	ret,
}

op_rr :: proc(p: ^Procedure, m: Mneumnoic, dest: Reg, src: Reg, pfx: Prefixes = {}) {
	instr := BinaryInstruction{.RR, m, dest, src, pfx}
	append(&p.buf, instr)
}
op_zo :: proc(p: ^Procedure, m: Mneumnoic, pfx: Prefixes = {}) {
	// TODO: can argless have prefixes?
	instr := ZeroOperandInstruction{m}
	append(&p.buf, instr)
}

Instruction :: union {
	Label,
	ZeroOperandInstruction,
	BinaryInstruction,
}

ZeroOperandInstruction :: struct {
	mneumnoic: Mneumnoic,
}
BinaryInstruction :: struct {
	encoding:  Encoding,
	mneumnoic: Mneumnoic,
	dest:      RMI,
	src:       RMI,
	prefixes:  Prefixes,
}
Encoding :: enum {
	ZO, // ZeroOperand
	I, // Immediate
	RR, // Alias to RM
	MR,
	RM,
	RI,
	MI,
}

mov_mr :: proc(p: ^Procedure, rm: RegMem, r: Reg, x: Prefixes = {}) {}
mov_mi :: proc(p: ^Procedure, rm: RegMem, i: Imm, x: Prefixes = {}) {}
mov_rm :: proc(p: ^Procedure, r: Reg, rm: RegMem, x: Prefixes = {}) {}
mov_ri :: proc(p: ^Procedure, r: Reg, i: Imm, x: Prefixes = {}) {}
mov_ro :: proc(p: ^Procedure, r: Reg, o: MOff, x: Prefixes = {}) {}


address_of :: proc {
	address_of_rm,
}
//[bx+si+0x188] [bx+si-0x7d] [cs:si+0x0]
address_of_rm :: proc(rm: RegMem) -> RegMem {
	return nil
}

mod_rm_byte :: proc(mod: u8, src: GeneralPurpose, dst: GeneralPurpose) -> u8 {
	// TODO: lookup indices, fix mod
	return u8(mod) << 6 | u8(dst) << 3 | u8(src)
}
