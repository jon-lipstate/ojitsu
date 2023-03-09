package ojitsu
// TODO: Address Forward usage for labels, jump ahead in the bitstream before label has been placed & addr known, handle with temp map to patch up after??
// Use a symbol / relocation table
Label :: struct {}
Procedure :: struct {
	buf: [dynamic]Instruction,
}
Asm :: struct {
	// Convention: procs[0] is always the 'main' proc
	procs: []Procedure,
}
Reg :: struct {
	reg: Gpr,
	// offset: Offset, // FIXME: I dont like this setup. i also need to do [AX+BX*3]
}
Offset :: struct {
	add: u16,
	mul: u8, // can only be 1,2,4,8
}
EAX :: Reg {
	reg = .EAX,
}
ECX :: Reg {
	reg = .ECX,
}
// TODO: add Size?
Operand :: union {
	Reg,
	Mem,
	Imm,
	Label,
}
RegMem :: union {
	Gpr,
	Reg,
	Mem,
}
MemReal :: struct {} // m32real, m64real, m80real
Mem :: struct {
	addr:   u64, // ??
	offset: Offset,
}
MemPtr :: struct {} // m16:16, m16:32
Imm :: union {
	u8,
	u16,
	u32,
	u64,
}
Rel :: struct {}
Ptr :: struct {} // jmp far [bx+si+0x7401]   jnz near 0x4856
MOff :: struct {}
