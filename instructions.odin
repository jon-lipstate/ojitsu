package ojitsu
import "core:fmt"
movs := map[InstrDesc]Instruction_ISR{}

// // TEMP CODE:
// TEMP_descriptors :: proc() {
// 	ids := map[InstrDesc]int{}
// 	descs := make([]InstrDesc, len(movs))
// 	row_num := 0
// 	for k, op in movs {
// 		sizes := make([]Size, len(op.operands), context.temp_allocator)
// 		for o, i in op.operands {
// 			sizes[i] = get_operand_size(o)
// 		}
// 		d := get_descriptor(op.arch, ..op.operands)
// 		fmt.printf("%X\n", d)
// 		assert(d not_in ids, fmt.tprintf("Row: %v, other:%v", row_num, ids[d]))
// 		ids[d] = row_num
// 		descs[row_num] = d
// 		row_num += 1
// 	}
// 	fmt.println("n_rows:", row_num)
// }
