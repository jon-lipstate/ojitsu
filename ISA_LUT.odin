package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

ISA_MAP :: map[InstrDesc]ISA_Instruction

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

// jcc :: #force_inline proc(p: ^Procedure, cc: ConditionCode) {/*coded_jump := `map[ConditionCode]Mnemonic` into correct code*/push_op(p, coded_jump)}
add :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .add, dest, src)}
mov :: #force_inline proc(p: ^Procedure, dest: Operand, src: Operand) {push_op(p, .mov, dest, src)}
ret :: #force_inline proc(p: ^Procedure) {push_op(p, .ret)}

//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\

//#sparse[Mnemonic]ISA_Map  // <--- Enumerated Array, sparse is for holes
ISA_LUT := [Mnemonic]^ISA_MAP {
	.mov = &movs,
	.add = &adds,
	.ret = &ret_far,
} // TODO: array of map..?
