package ojitsu
import "core:fmt"
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
InstrDesc :: distinct u64

get_descriptor :: proc(arch: Arch, operands: ..SizedKind) -> InstrDesc {
	spall.event_scope(&ctx, &buffer, #procedure)
	desc: InstrDesc = 0
	// use 12 bit spaces for each operand, starting at zero
	for op, i in operands {
		assert(i < 6) // TODO: why did i put 6, sb 4??
		class_val: u8 = 0
		switch op.kind {
		case .SegmentReg:
			class_val = 0
		case .Gpr:
			class_val = 1
		case .Mem:
			class_val = 2
		case .Imm:
			class_val = 3
		case .Offset:
			class_val = 4
		case .Invalid, .Gpr_or_Mem:
			panic("Invalid, RegMem not supported")
		}
		desc |= 1 << (u8(i) * 12 + class_val)
		size_val: u8 = 0
		#partial switch op.size {
		case .Bits_8:
			size_val = 0
		case .Bits_16:
			size_val = 1
		case .Bits_32:
			size_val = 2
		case .Bits_64:
			size_val = 3
		case:
			panic("unhandled_size") // TODO: 128-512
		}
		desc |= 1 << (u8(i) * 12 + 5 + size_val) // +5 moves above desc
	}
	return desc
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
get_sized_kind :: proc(arg: Operand) -> SizedKind {
	spall.event_scope(&ctx, &buffer, #procedure)
	switch a in arg {
	// case (Gpr):
	// 	return SizedKind{.Gpr, reg_to_size(a)}
	case (Reg):
		return SizedKind{.Gpr, reg_to_size(a.reg)}
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
	spall.event_scope(&ctx, &buffer, #procedure)
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
	spall.event_scope(&ctx, &buffer, #procedure)
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
