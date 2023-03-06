package asmdb_parser
// import "core:fmt"
// import "core:strconv"
// import "core:strings"

// FPU_Flag :: enum {
// 	Invalid,
// 	FPU,
// 	FPU_POP,
// 	FPU_POP_2, //FPU_POP=2
// 	FPU_PUSH,
// 	FPU_TOP,
// 	FPU_TOP_n1, // FPU_TOP=-1
// 	FPU_TOP_1, //FPU_TOP=+1
// }
// parse_fpu :: proc(p: ^Parser, token: Token) -> (bool, FPU_Flag) {
// 	next := parser_peek(p)
// 	switch token.text {
// 	case "FPU":
// 		return true, .FPU
// 	case "FPU_PUSH":
// 		return true, .FPU_PUSH
// 	case "FPU_POP":
// 		if next.kind != .Equals {
// 			return true, .FPU_POP
// 		}
// 		parser_consume(p)
// 		n := parser_consume(p)
// 		assert(n.text == "2")
// 		return true, .FPU_POP_2
// 	case "FPU_TOP":
// 		if next.kind != .Equals {
// 			return true, .FPU_TOP
// 		}
// 		parser_consume(p)
// 		n := parser_consume(p)
// 		if n.kind == .Plus {
// 			n := parser_consume(p)
// 			assert(n.text == "1")
// 			return true, .FPU_TOP_1
// 		} else if n.kind == .Minus {
// 			n := parser_consume(p)
// 			assert(n.text == "1")
// 			return true, .FPU_TOP_n1

// 		}
// 	}
// 	return false, .Invalid
// }

// control_map := map[string]Control {
// 	"None"   = .None,
// 	"Call"   = .Call,
// 	"Return" = .Return,
// 	"Branch" = .Branch,
// 	"Jump"   = .Jump,
// }

// Control :: enum {
// 	None,
// 	Call,
// 	Return,
// 	Branch,
// 	Jump,
// }

// Meta :: struct {
// 	flags_overflow:                  FlagParams, // OF
// 	flags_sign:                      FlagParams, // SF
// 	flags_zero:                      FlagParams, // ZF
// 	flags_adjust:                    FlagParams, // AF
// 	flags_parity:                    FlagParams, // PF
// 	flags_carry:                     FlagParams, // CF
// 	flags_direction:                 FlagParams, // DF
// 	flags_interrupt_enable:          FlagParams, // IF
// 	flags_trap:                      FlagParams, // TF
// 	C0:                              FlagParams, // 
// 	C1:                              FlagParams, // 
// 	C2:                              FlagParams, // 
// 	C3:                              FlagParams, // 
// 	fpu:                             FPU_Flag,
// 	//
// 	arch:                            ArchFlags, // ANY X64 X86
// 	extensions:                      Extensions,
// 	other:                           [dynamic]string,
// 	control:                         Control,
// 	privilege_lo:                    bool, //PRIVILEGE=L0 assert L0 incase others
// 	deprecated:                      bool,
// 	alt_form:                        bool,
// 	msr:                             FlagParams,
// 	xcr:                             FlagParams,
// 	ac:                              u8, //AC=0 AC=1
// 	volatile:                        bool,
// 	prefix:                          PrefixFlags,
// 	//MOVE TO REGISTERS??
// 	// Other:
// 	flags_io_privilege_level:        FlagParams, // iopl
// 	flags_nested_task:               FlagParams, // nt
// 	flags_resume:                    FlagParams, // rf
// 	flags_virtual_8086:              FlagParams, // vm
// 	flags_virtual_interrupt:         FlagParams, // vif
// 	flags_virtual_interrupt_pending: FlagParams, // vip
// 	flags_cpuid:                     FlagParams, // cpuid
// 	// X87 - "group": "X87CW.EXC"
// 	// x87cw_invalid_op:                FlagParams, // Invalid operation
// 	// x87cw_denormal:                  FlagParams, // Dernormalized
// 	// x87cw_zero_divide:               FlagParams, // Division by zero
// 	// x87cw_overflow:                  FlagParams, // Overflow
// 	// x87cw_underflow:                 FlagParams, // Underflow
// 	// x87cw_precision:                 FlagParams, // Loss of precision
// 	// x87cw_precision_control:         FlagParams, // PC
// 	// x87cw_rounding_control:          FlagParams, // RC
// 	// // x87 - "group": "X87SW.EXC"
// 	// x87sw_invalid_op:                FlagParams, // 
// 	// x87sw_denormal:                  FlagParams, // 
// 	// x87sw_zero_divide:               FlagParams, // 
// 	// x87sw_overflow:                  FlagParams, // 
// 	// x87sw_underflow:                 FlagParams, // 
// 	// x87sw_precision:                 FlagParams, // 
// 	// x87sw_stack_fault:               FlagParams, // 
// 	// x87sw_exception_flag:            FlagParams, // 
// 	// x87sw_c0:                        FlagParams, // 
// 	// x87sw_c1:                        FlagParams, // 
// 	// x87sw_c2:                        FlagParams, // 
// 	// x87sw_c3:                        FlagParams, // 
// 	// x87sw_fpu_stack_top:             FlagParams, // TOP
// }
// //OF=W SF=W ZF=W AF=W PF=W CF=X"
// FlagParams :: enum {
// 	Invalid, // default/zero value
// 	Executes,
// 	Writes,
// 	Reads,
// 	Zeros,
// 	Undefined,
// }
// ArchFlags :: bit_set[ArchFlag]
// ArchFlag :: enum {
// 	X64,
// 	X86,
// }
// PrefixFlags :: bit_set[PrefixFlag]
// PrefixFlag :: enum {
// 	Lock,
// 	ImplicitLock,
// 	XAcquire,
// 	XRelease,
// 	REPNE,
// 	RepIgnored,
// 	REP,
// }

// parse_meta :: proc(s: string, allocator := context.temp_allocator) -> Meta {
// 	context.temp_allocator = allocator // TODO: i think i need perm allocs for strings...
// 	t := init_tokenizer(s)
// 	scan_tokens(&t)
// 	p := Parser{t.tokens, 0}
// 	meta := Meta{}
// 	for parser_peek(&p).kind != .EOF {
// 		token := parser_consume(&p)
// 		#partial switch token.kind {
// 		case .Number:
// 			fmt.println("NUMBER", token)
// 		case .Ident:
// 			if ok, arch := parse_arch(&p, token); ok {
// 				meta.arch += arch
// 				continue
// 			}
// 			if parse_meta_flags(&p, &meta, token) {
// 				continue
// 			}
// 			if ok, prefix := parse_prefixes(&p, token); ok {
// 				meta.prefix += prefix
// 				continue
// 			}
// 			if token.text == "Control" {
// 				parser_consume(&p)
// 				ctrl := parser_consume(&p).text
// 				meta.control = control_map[ctrl]
// 				continue
// 			}
// 			// msr is also extension so must go first
// 			if token.text == "MSR" {
// 				parser_consume(&p)
// 				v := parser_consume(&p)
// 				meta.msr = flag_to_enum[v.text]
// 				continue
// 			}
// 			if ok, ext := parse_extensions(&p, token); ok {
// 				meta.extensions += {ext}
// 				continue
// 			}
// 			if ok, fpu := parse_fpu(&p, token); ok {
// 				meta.fpu = fpu
// 				continue
// 			}
// 			if parse_other(&p, &meta, token) {
// 				continue
// 			}
// 			fmt.println("<!> UNCAUGHT Meta (prev-val):", p.tokens[p.current - 3].text, p.tokens[p.current - 2].text, token.text)
// 		case .Equals:
// 			fmt.println("EQ:", parser_peek(&p))
// 		}
// 	}
// 	return meta
// }

// parse_arch :: proc(p: ^Parser, token: Token) -> (bool, ArchFlags) {
// 	switch token.text {
// 	case "ANY":
// 		return true, ArchFlags{.X64, .X86}
// 	case "X86":
// 		return true, ArchFlags{.X86}
// 	case "X64":
// 		return true, ArchFlags{.X64}
// 	}
// 	return false, {}
// }
// parse_prefixes :: proc(p: ^Parser, token: Token) -> (bool, PrefixFlags) {
// 	if token.text in prefixes {
// 		return true, prefixes[token.text]
// 	}
// 	return false, {}
// }
// prefixes := map[string]PrefixFlags {
// 	"_ILock" = {.Lock, .ImplicitLock},
// 	"_XLock" = {.Lock, .XAcquire, .XRelease},
// 	"XAcquire" = {.XAcquire},
// 	"XRelease" = {.XRelease},
// 	"BND" = {.REPNE, .RepIgnored},
// 	"_Rep" = {.REP, .REPNE},
// 	"DummyRep" = {.REP, .REPNE, .RepIgnored},
// }
// parse_meta_flags :: proc(p: ^Parser, m: ^Meta, token: Token) -> bool {
// 	if token.text not_in flag_strings do return false
// 	eq := parser_consume(p)
// 	assert(eq.kind == .Equals)
// 	token_value := parser_consume(p).text
// 	v := flag_to_enum[token_value]
// 	switch token.text {
// 	case "OF":
// 		m.flags_overflow = v
// 	case "SF":
// 		m.flags_sign = v
// 	case "ZF":
// 		m.flags_zero = v
// 	case "AF":
// 		m.flags_adjust = v
// 	case "PF":
// 		m.flags_parity = v
// 	case "CF":
// 		m.flags_carry = v
// 	case "DF":
// 		m.flags_direction = v
// 	case "IF":
// 		m.flags_interrupt_enable = v
// 	case "TF":
// 		m.flags_trap = v
// 	case "C0":
// 		m.C0 = v
// 	case "C1":
// 		m.C1 = v
// 	case "C2":
// 		m.C2 = v
// 	case "C3":
// 		m.C3 = v
// 	case:
// 		return false
// 	}
// 	return true
// }
// parse_other :: proc(p: ^Parser, m: ^Meta, token: Token) -> bool {
// 	if token.text == "Volatile" {
// 		m.volatile = true
// 	} else if token.text == "Deprecated" {
// 		m.deprecated = true
// 	} else if token.text == "AltForm" {
// 		m.alt_form = true
// 	} else if token.text == "PRIVILEGE" {
// 		parser_consume(p)
// 		l0 := parser_consume(p)
// 		assert(l0.text == "L0")
// 		m.privilege_lo = true
// 	} else if token.text == "XCR" {
// 		parser_consume(p)
// 		v := parser_consume(p)
// 		m.xcr = flag_to_enum[v.text]
// 	} else if token.text == "AC" {
// 		parser_consume(p)
// 		v := parser_consume(p)
// 		m.ac = u8(strconv.atoi(v.text))
// 	} else {
// 		fmt.println("NO MATCH", token.text)
// 		return false
// 	}
// 	return true
// }

// flag_strings := map[string]u8 {
// 	"OF" = 1,
// 	"SF" = 1,
// 	"ZF" = 1,
// 	"AF" = 1,
// 	"PF" = 1,
// 	"CF" = 1,
// 	"DF" = 1,
// 	"IF" = 1,
// 	"TF" = 1,
// 	"C0" = 7, // x87
// 	"C1" = 7, // x87
// 	"C2" = 7, // x87
// 	"C3" = 7, // x87
// 	"C4" = 7, // x87
// }
// flag_to_enum := map[string]FlagParams {
// 	"X" = .Executes,
// 	"W" = .Writes,
// 	"R" = .Reads,
// 	"0" = .Zeros,
// 	"U" = .Undefined,
// }
// meta := map[string]string {
// 	// "Control"    = "describes control flow",
// 	"Volatile"   = "Instruction can have side effects (hint for instruction scheduler).",
// 	"Deprecated" = "Deprecated",
// 	"AltForm"    = "Alternative form that is shorter, but has restrictions.",
// 	"AliasOf"    = "Instruction is an alias to another instruction, must apply to all instructions within the same group.",
// 	"EncodeAs"   = "Similar to AliasOf, but doesn't apply to all instructions in the group.",
// }
// parse_extensions :: proc(p: ^Parser, token: Token) -> (bool, Extension) {
// 	if parser_peek(p).kind == .Minus && token.text in extension_map {
// 		parser_consume(p)
// 		vl := parser_consume(p)
// 		assert(vl.text == "VL")
// 		c := []string{token.text, "-VL"}
// 		str := strings.concatenate(c, context.temp_allocator)
// 		if str not_in extension_map {
// 			fmt.println(str)
// 		}
// 		// assert(str in extension_map)
// 		return true, extension_map[str]
// 	}
// 	if token.text not_in extension_map {
// 		return false, .Invalid
// 	}
// 	return true, extension_map[token.text]
// }
// Extensions :: bit_set[Extension]
// Extension :: enum {
// 	Invalid,
// 	_3DNOW,
// 	_3DNOW2,
// 	ADX,
// 	AESNI,
// 	AMX_TILE,
// 	AMX_BF16,
// 	AMX_INT8,
// 	AVX,
// 	AVX_VNNI,
// 	AVX2,
// 	AVX512_4FMAPS,
// 	AVX512_4VNNIW,
// 	AVX512_BF16,
// 	AVX512_BF16_VL, // NEW
// 	AVX512_BITALG,
// 	AVX512_BITALG_VL, //new
// 	AVX512_BW,
// 	AVX512_BW_VL, // NEW
// 	AVX512_CDI,
// 	AVX512_CDI_VL, //NEW
// 	AVX512_DQ,
// 	AVX512_DQ_VL, //NEW
// 	AVX512_ERI,
// 	AVX512_F,
// 	AVX512_F_VL, // NEW
// 	AVX512_FP16,
// 	AVX512_FP16_VL, //new
// 	AVX512_IFMA,
// 	AVX512_IFMA_VL,
// 	AVX512_PFI,
// 	AVX512_VBMI,
// 	AVX512_VBMI_VL, //new
// 	AVX512_VBMI2,
// 	AVX512_VBMI2_VL, // new
// 	AVX512_VNNI,
// 	AVX512_VNNI_VL, //new
// 	AVX512_VL,
// 	AVX512_VP2INTERSECT,
// 	AVX512_VPOPCNTDQ,
// 	AVX512_VPOPCNTDQ_VL, //
// 	BMI,
// 	BMI2,
// 	CET_IBT,
// 	CET_SS,
// 	CLDEMOTE,
// 	CLFLUSH,
// 	CLFLUSHOPT,
// 	CLWB,
// 	CLZERO,
// 	CMOV,
// 	CMPXCHG8B,
// 	CMPXCHG16B,
// 	ENCLV,
// 	ENQCMD,
// 	F16C,
// 	FMA,
// 	FMA4,
// 	FSGSBASE,
// 	FXSR,
// 	GEODE,
// 	HLE,
// 	HRESET,
// 	GFNI,
// 	I486,
// 	LAHFSAHF,
// 	LWP,
// 	LZCNT,
// 	MCOMMIT,
// 	MMX,
// 	MMX2,
// 	MONITOR,
// 	MONITORX,
// 	MOVBE,
// 	MOVDIR64B,
// 	MOVDIRI,
// 	MPX,
// 	MSR,
// 	OSPKE,
// 	PCLMULQDQ,
// 	PCOMMIT,
// 	PCONFIG,
// 	POPCNT,
// 	PREFETCHW,
// 	PREFETCHWT1,
// 	PTWRITE,
// 	RDPID,
// 	RDPRU,
// 	RDRAND,
// 	RDSEED,
// 	RDTSC,
// 	RDTSCP,
// 	RTM,
// 	SEAM,
// 	SERIALIZE,
// 	SHA,
// 	SKINIT,
// 	SMAP,
// 	SMX,
// 	SNP,
// 	SSE,
// 	SSE2,
// 	SSE3,
// 	SSE4_1,
// 	SSE4_2,
// 	SSE4A,
// 	SSSE3,
// 	SVM,
// 	TBM,
// 	TSX,
// 	TSXLDTRK,
// 	UINTR,
// 	VAES,
// 	VPCLMULQDQ,
// 	VMX,
// 	WAITPKG,
// 	WBNOINVD,
// 	XOP,
// 	XSAVE,
// 	XSAVEC,
// 	XSAVEOPT,
// 	XSAVES,
// }

// extension_map := map[string]Extension {
// 	"3DNOW"               = ._3DNOW,
// 	"3DNOW2"              = ._3DNOW2,
// 	"ADX"                 = .ADX,
// 	"AESNI"               = .AESNI,
// 	"AMX_TILE"            = .AMX_TILE,
// 	"AMX_BF16"            = .AMX_BF16,
// 	"AMX_INT8"            = .AMX_INT8,
// 	"AVX"                 = .AVX,
// 	"AVX_VNNI"            = .AVX_VNNI,
// 	"AVX2"                = .AVX2,
// 	"AVX512_4FMAPS"       = .AVX512_4FMAPS,
// 	"AVX512_4VNNIW"       = .AVX512_4VNNIW,
// 	"AVX512_BF16"         = .AVX512_BF16,
// 	"AVX512_BF16-VL"      = .AVX512_BF16_VL,
// 	"AVX512_BITALG"       = .AVX512_BITALG,
// 	"AVX512_BITALG-VL"    = .AVX512_BITALG_VL,
// 	"AVX512_BW"           = .AVX512_BW,
// 	"AVX512_BW-VL"        = .AVX512_BW_VL,
// 	"AVX512_CDI"          = .AVX512_CDI,
// 	"AVX512_CDI-VL"       = .AVX512_CDI_VL,
// 	"AVX512_DQ"           = .AVX512_DQ,
// 	"AVX512_DQ-VL"        = .AVX512_DQ_VL,
// 	"AVX512_ERI"          = .AVX512_ERI,
// 	"AVX512_F"            = .AVX512_F,
// 	"AVX512_F-VL"         = .AVX512_F_VL,
// 	"AVX512_FP16"         = .AVX512_FP16,
// 	"AVX512_FP16-VL"      = .AVX512_FP16_VL,
// 	"AVX512_IFMA"         = .AVX512_IFMA,
// 	"AVX512_IFMA-VL"      = .AVX512_IFMA_VL,
// 	"AVX512_PFI"          = .AVX512_PFI,
// 	"AVX512_VBMI"         = .AVX512_VBMI,
// 	"AVX512_VBMI-VL"      = .AVX512_VBMI_VL,
// 	"AVX512_VBMI2"        = .AVX512_VBMI2,
// 	"AVX512_VBMI2-VL"     = .AVX512_VBMI2_VL,
// 	"AVX512_VNNI"         = .AVX512_VNNI,
// 	"AVX512_VNNI-VL"      = .AVX512_VNNI_VL,
// 	"AVX512_VL"           = .AVX512_VL,
// 	"AVX512_VP2INTERSECT" = .AVX512_VP2INTERSECT,
// 	"AVX512_VPOPCNTDQ"    = .AVX512_VPOPCNTDQ,
// 	"AVX512_VPOPCNTDQ-VL" = .AVX512_VPOPCNTDQ_VL,
// 	"BMI"                 = .BMI,
// 	"BMI2"                = .BMI2,
// 	"CET_IBT"             = .CET_IBT,
// 	"CET_SS"              = .CET_SS,
// 	"CLDEMOTE"            = .CLDEMOTE,
// 	"CLFLUSH"             = .CLFLUSH,
// 	"CLFLUSHOPT"          = .CLFLUSHOPT,
// 	"CLWB"                = .CLWB,
// 	"CLZERO"              = .CLZERO,
// 	"CMOV"                = .CMOV,
// 	"CMPXCHG8B"           = .CMPXCHG8B,
// 	"CMPXCHG16B"          = .CMPXCHG16B,
// 	"ENCLV"               = .ENCLV,
// 	"ENQCMD"              = .ENQCMD,
// 	"F16C"                = .F16C,
// 	"FMA"                 = .FMA,
// 	"FMA4"                = .FMA4,
// 	"FSGSBASE"            = .FSGSBASE,
// 	"FXSR"                = .FXSR,
// 	"GEODE"               = .GEODE,
// 	"HLE"                 = .HLE,
// 	"HRESET"              = .HRESET,
// 	"GFNI"                = .GFNI,
// 	"I486"                = .I486,
// 	"LAHFSAHF"            = .LAHFSAHF,
// 	"LWP"                 = .LWP,
// 	"LZCNT"               = .LZCNT,
// 	"MCOMMIT"             = .MCOMMIT,
// 	"MMX"                 = .MMX,
// 	"MMX2"                = .MMX2,
// 	"MONITOR"             = .MONITOR,
// 	"MONITORX"            = .MONITORX,
// 	"MOVBE"               = .MOVBE,
// 	"MOVDIR64B"           = .MOVDIR64B,
// 	"MOVDIRI"             = .MOVDIRI,
// 	"MPX"                 = .MPX,
// 	"MSR"                 = .MSR,
// 	"OSPKE"               = .OSPKE,
// 	"PCLMULQDQ"           = .PCLMULQDQ,
// 	"PCOMMIT"             = .PCOMMIT,
// 	"PCONFIG"             = .PCONFIG,
// 	"POPCNT"              = .POPCNT,
// 	"PREFETCHW"           = .PREFETCHW,
// 	"PREFETCHWT1"         = .PREFETCHWT1,
// 	"PTWRITE"             = .PTWRITE,
// 	"RDPID"               = .RDPID,
// 	"RDPRU"               = .RDPRU,
// 	"RDRAND"              = .RDRAND,
// 	"RDSEED"              = .RDSEED,
// 	"RDTSC"               = .RDTSC,
// 	"RDTSCP"              = .RDTSCP,
// 	"RTM"                 = .RTM,
// 	"SEAM"                = .SEAM,
// 	"SERIALIZE"           = .SERIALIZE,
// 	"SHA"                 = .SHA,
// 	"SKINIT"              = .SKINIT,
// 	"SMAP"                = .SMAP,
// 	"SMX"                 = .SMX,
// 	"SNP"                 = .SNP,
// 	"SSE"                 = .SSE,
// 	"SSE2"                = .SSE2,
// 	"SSE3"                = .SSE3,
// 	"SSE4_1"              = .SSE4_1,
// 	"SSE4_2"              = .SSE4_2,
// 	"SSE4A"               = .SSE4A,
// 	"SSSE3"               = .SSSE3,
// 	"SVM"                 = .SVM,
// 	"TBM"                 = .TBM,
// 	"TSX"                 = .TSX,
// 	"TSXLDTRK"            = .TSXLDTRK,
// 	"UINTR"               = .UINTR,
// 	"VAES"                = .VAES,
// 	"VPCLMULQDQ"          = .VPCLMULQDQ,
// 	"VMX"                 = .VMX,
// 	"WAITPKG"             = .WAITPKG,
// 	"WBNOINVD"            = .WBNOINVD,
// 	"XOP"                 = .XOP,
// 	"XSAVE"               = .XSAVE,
// 	"XSAVEC"              = .XSAVEC,
// 	"XSAVEOPT"            = .XSAVEOPT,
// 	"XSAVES"              = .XSAVES,
// }
