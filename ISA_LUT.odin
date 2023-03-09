package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
ISR_MAP :: map[InstrDesc]ISA_Instruction
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
//#sparse[Mnemonic]ISR_MAP  // <--- Enumerated Array, sparse is for holes
ISR := map[Mnemonic]ISR_MAP {
	.mov = movs,
	.add = adds,
} // TODO: array of map..?
