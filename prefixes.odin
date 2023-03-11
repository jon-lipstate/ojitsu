package ojitsu
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
LegacyPrefixes :: bit_set[LegacyPrefixFlag]
LegacyPrefixFlag :: enum {
	None,
	Escape,
	EscapeTwice, // 0F 0F (3dNow!)
	//0F38 - TODO: MISSING 38 PREFIX
	// Group 1:
	BND,
	REPNZ, // Alias: REPNZ. Repeat Not Zero; Applies to String & IO, Mandatory for some
	REP, // Alias: REPE/REPZ. Repeat
	Lock,
	// Group 2:
	CS_Override,
	SS_Override,
	DS_Override,
	ES_Override,
	FS_Override,
	GS_Override,
	BranchNotTaken, // Used with Jump on Conditions (eg @cold)
	BranchTaken, // Used with JCC
	// Group 3:
	OpSizeOverride, // swap between 16-32 bit ops, flag flips to non-default size
	// Group 4:
	AddressSizeOverride, // swap between 16-32 bit addrs, flag flips to non-default size
}
PREFIX_VALUES := map[LegacyPrefixFlag]u8 {
	.Escape              = 0x0F,
	.Lock                = 0xF0,
	.BND                 = 0xF2,
	.REPNZ               = 0xF2,
	.REP                 = 0xF3,
	.CS_Override         = 0x2E,
	.SS_Override         = 0x36,
	.DS_Override         = 0x3E,
	.ES_Override         = 0x26,
	.FS_Override         = 0x64,
	.GS_Override         = 0x65,
	.BranchNotTaken      = 0x2E,
	.BranchTaken         = 0x3E,
	.OpSizeOverride      = 0x66,
	.AddressSizeOverride = 0x67,
}
//BND prefix is encoded using F2H if the following conditions are true:
// CPUID.(EAX=07H, ECX=0):EBX.MPX[bit 14] is set.
// BNDCFGU.EN and/or IA32_BNDCFGS.EN is set.
// When the F2 prefix precedes a near CALL, a near RET, a near JMP, a short Jcc, or a near Jcc instruction
// (see Appendix E, "Intel Memory Protection Extensions", of the Intel 64 and IA-32 Architectures
// Software Developer's Manual, Volume 1).
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
REX :: enum {
	REX   = 0b0100_0000,
	REX_W = 0b0100_1000, // 0:Op by CS.D, 1:64-bit
	REX_R = 0b0100_0100, // Mod-RM Reg-Field
	REX_X = 0b0100_0010, // SIB Index
	REX_B = 0b0100_0001, // Mod-RM RM-Field
}
//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
VectorPrefix :: bit_set[VectorFlag]
VectorFlag :: enum {
	Invalid,
	//Kind
	VEX,
	EVEX,
	XOP,
	//Size
	Size_128,
	Size_256,
	Size_512,
	//
	L0,
	L1,
	LZ,
	LIG,
	//
	Implied_0F,
	Implied_0F38,
	Implied_0F3A,
	//
	NP,
	Implied_66,
	Implied_F2,
	Implied_F3,
	//
	W0,
	W1,
	WIG,
	//
	M08,
	M09,
	M0A,
	P0,
	//
	MAP5,
	MAP6,
}
