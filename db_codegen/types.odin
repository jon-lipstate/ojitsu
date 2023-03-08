package ojitsu_parser
//xed-reg-role.enum
RegisterRole :: enum {
	Invalid,
	Normal,
	SegmentReg0, // 0=first
	SegmentReg1, // 1=second
	Base0,
	Base1,
	Index,
}
OperandVisibility :: enum {
	Invalid,
	Explicit,
	Implicit, // part of opcode, Listed as an operand
	Suppressed, // part of opcode, not listed
}

Actions :: bit_set[ActionFlag]
ActionFlag :: enum {
	Invalid,
	Read,
	Write,
	Conditional,
}
FlagAction :: enum {
	Undefined,
	Test, // Read
	Modify, // Write
	Zero, // Write 0
	Pop, // Write from Stack
	One, // Writes 1
	AH, // Write from AH
}

Flags :: enum {
	Invalid,
	Overflow,
	Sign,
	Zero,
	Auxillary,
	Parity,
	Carry,
	Direction,
	VirtualInterrupt,
	IOPrivigeLevel,
	Inturrupt,
	AlignmentCheck,
	Virtual8086Mode,
	Resume,
	NestedTask,
	Trap,
	Id,
	VirtualInterruptPending,
	FC0,
	FC1,
	FC2,
	FC3,
}

ModRM_State :: struct {
	use_mod: bool,
	mod_NE:  u8,
	mm:      u8,
	//
	use_reg: bool,
	reg:     u8,
	//
	use_rm:  bool,
	rm:      u8,
}
