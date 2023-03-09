package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
ISA_MAP :: map[InstrDesc]ISA_Instruction
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
//#sparse[Mnemonic]ISA_Map  // <--- Enumerated Array, sparse is for holes
ISA_LUT := map[Mnemonic]ISA_MAP {
	.mov = movs,
	.add = adds,
	.ret = ret_far,
} // TODO: array of map..?
