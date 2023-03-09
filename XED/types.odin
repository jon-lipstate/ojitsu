package ojitsu_xed

// Dispacement :: struct {
// 	disp: i64, //The value of the displacement
// 	bits: u32, //The width of the displacement in bits. Typically 8 or 32.
// }
// Memop :: struct {
// 	seg:   reg_enum,
// 	seg:   reg_enum,
// 	seg:   reg_enum,
// 	scale: u32,
// 	disp:  Dispacement,
// }

// Operand_Kind :: enum {
// 	Invalid,
// 	BranchDisp,
// 	Reg,
// 	Imm0,
// 	SImm0,
// 	Imm1,
// 	Ptr,
// 	Seg0,
// 	Seg1,
// 	Other,
// }
// Encoder_Operand :: struct {
// 	kind:       Operand_Kind,
// 	width_bits: u32,
// 	using _:    struct #raw_union {
// 		reg:         reg_enum,
// 		branch_disp: i32,
// 		imm0:        u64,
// 		imm1:        u8,
// 		other:       struct {
// 			name: reg_enum,
// 			val:  u32,
// 		},
// 		mem:         Memop,
// 	},
// }

// Encoder_Instruction :: struct {
// 	mode:         u8,
// 	iclass:       u8,
// 	eff_op_width: u32, //
// 	prefixes:     Prefixes,
// 	operands:     []Encoder_Operand,
// }

// State :: struct {
//     mmode:Machine_Mode,
//     addr_width:,
// }
