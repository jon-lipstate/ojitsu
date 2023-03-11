package ojitsu
import "core:fmt"
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
InstrDesc :: distinct u64

// TODO: i dont think this hashing method will extend to avx...
get_descriptor :: proc(arch: Arch, operands: ..SizedKind) -> InstrDesc {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	desc: InstrDesc = 0
	// use 12 bit spaces for each operand, starting at zero
	for op, i in operands {
		assert(i < 6) // TODO: why did i put 6, sb 4??
		kind_bit_offset: u8 = 0
		switch op.kind {
		case .SegmentReg:
			kind_bit_offset = 0
		case .Reg:
			kind_bit_offset = 1
		// case .Reg_or_Mem:
		// 	kind_bit_offset = 1 | 2
		case .Mem:
			kind_bit_offset = 2
		case .Imm:
			kind_bit_offset = 3
		case .Offset:
			kind_bit_offset = 4
		case .Invalid, .BranchDisp, .Reg_or_Mem:
			fmt.println(operands)
			panic("not supported yet")
		}
		desc |= 1 << (u8(i) * 12 + kind_bit_offset)
		size_bit_offset: u8 = 0
		#partial switch op.size {
		case .Bits_8:
			size_bit_offset = 0
		case .Bits_16:
			size_bit_offset = 1
		case .Bits_32:
			size_bit_offset = 2
		case .Bits_64:
			size_bit_offset = 3
		case:
			panic("unhandled_size") // TODO: 128-512
		}
		desc |= 1 << (u8(i) * 12 + 5 + size_bit_offset) // +5 moves above desc
	}
	return desc
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
get_sized_kind :: proc(arg: Operand) -> SizedKind {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	switch a in arg {
	// case (Gpr):
	// 	return SizedKind{.Gpr, reg_to_size(a)}
	case (Reg):
		return SizedKind{.Reg, reg_to_size(a.reg)}
	case (Mem):
		panic("not impl")
	case (Imm):
		return SizedKind{.Imm, imm_to_size(a)}
	case (Label):
		panic("invalid path..?")
	}
	return SizedKind{.Invalid, .Invalid}
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
reg_to_size :: proc(gp: Gpr) -> Size {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	#partial switch gp {
	case .AL, .AH, .BL, .BH, .CL, .CH, .DH, .DIL, .SIL, .SPL:
		return .Bits_8
	case .AX, .BX, .CX, .DX:
		return .Bits_16
	case .EAX, .EBX, .ECX, .EDX, .EBP, .EDI, .ESI, .ESP:
		return .Bits_32
	case .RAX, .RBX, .RCX, .RDX, .RSP, .RDI, .RSI, .RBP, .R0, .R1, .R2, .R3, .R4, .R5, .R6, .R7, .R8, .R9, .R10, .R11, .R12, .R13, .R14, .R15:
		return .Bits_64
	case:
		fmt.println(gp)
		panic("missing")
	}
}
imm_to_size :: proc(imm: Imm) -> Size {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	switch i in imm {
	case (u8):
		return .Bits_8
	case (u16):
		return .Bits_16
	case (u32):
		return .Bits_32
	case (u64):
		return .Bits_64
	}
	return .Invalid
}
