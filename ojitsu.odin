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
	rax := reg(.RAX) // fn queries bit-size for use in the mov switches
	rdi := reg(.RDI)
	mov(main, rax, reg(.RCX))
	mov(main, rdi, 0x0) // set loop counter to zero
	//
	loop := insert_label(&a) // TODO: does a label actually neep a Procedure? i am thinking no...
	// add(main, rax, rax) // double again
	// add(main, rdi, 0x1)
	// cmp(main, rdi, 0xA) // for 0..10
	// jne(main)
	//
	// ret(main)
	// //
	// fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)
}
simple_example :: proc() {
	a := make_assembler()
	main := get_main_proc(&a)
	rax := reg(.RAX) // fn gets bit-size
	rcx := reg(.RCX)
	mov(main, rax, reg(.RCX))
	// add(main, rax, rax)
	// ret(main)
	// fn_ptr:= transmute(proc(x:i64)->i64)assemble(&a)
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

// `zax` - mapped to either `eax` or `rax` Z prefix for native size

// ["mov, "W:r64/m64, r64", "MR", "REX.W 89 /r"   , "X64 XRelease"],
// ["mov, "W:r64/m64, id" , "MI", "REX.W C7 /0 id", "X64 XRelease"],
// ["mov, "W:r64, r64/m64", "RM", "REX.W 8B /r"   , "X64"],

@(export)
mov :: proc {
	mov_rr,
	mov_mr,
	mov_mi,
	mov_rm,
	mov_ri,
	mov_ro,
}
mov_rr :: proc(p: ^Procedure, rd: Reg, rs: Reg, x: Prefixes = {}) {
	// Todo: prefixes, rex
	// if is_rex(rd){
	// 	append(&p.buf,123)
	// }
	// apply_prefixes(&p.buf,p)
	append(&p.buf, mod_rm_byte(0x11, rs.reg, rd.reg))

	switch rd.bits {
	case 64:
		append(&p.buf, 0x89)
	}
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
