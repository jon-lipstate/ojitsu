package asmdb_parser
// import "core:fmt"
// // import "core:strings"
// import "core:strconv"

// Operand_Flag :: enum {
// 	Optional,
// 	Implicit,
// 	Commutative,
// 	// ZExt,
// 	ReadAccess,
// 	WriteAccess,
// 	ImplicitZeroExtend,
// 	RegisterSlice, // eg xmm[63:0]
// 	FPU_ST, // eg st(i|0-7)
// }
// Operand_Flags :: bit_set[Operand_Flag]

// Operand :: struct {
// 	// type:          string, // Type of the operand ("reg", "reg-list", "mem", "reg/mem", "imm", "rel").
// 	flags:     Operand_Flags,
// 	//
// 	reg:       string, // Register operand's definition.
// 	mem:       string, // Memory operand's definition.
// 	imm:       string, //--int-- Immediate operand's size.
// 	rel:       string, //--int-- Relative displacement operand's size.
// 	//
// 	bit_range: [2]int, // TODO: Move onto Register Struct..?
// 	fpu_index: int, // st(i|0-7)
// 	offset:    int, // 3 of zmm+3
// 	meta:      string, // zdi bit of <es:zdi>
// 	avx_flags: string, // {kz}
// 	xmm:       bool,
// 	ymm:       bool,
// 	zmm:       bool,
// 	tmm:       bool,
// 	b:         string,
// 	vm:        string,
// 	// restrict:      string, // Operand is restricted (specific register or immediate value).
// 	// //
// 	// reg_type:      string, // Register operand's type.
// 	// reg_index_rel: int, // Register index is relative to the previous register operand index (0 if not).
// 	// mem_size:      int, // Memory operand's size.
// 	// imm_sign:      string, // Immediate sign (any / signed / unsigned).
// 	// imm_value:     bool, // Immediate value - `null` or `1` (only used by shift/rotate instructions).
// 	// //
// 	// rwx_index:     int, // Read/Write (RWX) index.
// 	// rwx_width:     int, // Read/Write (RWX) width.
// 	// // extended class:
// 	// memSeg:        string, // Segment specified with register that is used to perform a memory IO.
// 	// memOff:        bool, // Memory operand is an absolute offset (only a specific version of MOV).
// 	// memFar:        bool, // Memory is a far pointer (includes segment in first two bytes).
// 	// vsibReg:       string, // AVX VSIB register type (xmm/ymm/zmm).
// 	// vsibSize:      int, // AVX VSIB register size (32/64).
// 	// bcstSize:      int, // AVX-512 broadcast size.
// }

// mmm_parse_operand :: proc(str: string) -> Operand {
// 	op := Operand{}

// 	return op
// }

// // Get size of an immediate `s` [in bits].
// imm_size :: proc(s: string) -> int {
// 	switch s {
// 	case "1":
// 		return 8
// 	case "i4", "u4", "/is4":
// 		return 4
// 	case "ib", "ub":
// 		return 8
// 	case "iw", "uw":
// 		return 16
// 	case "id", "ud":
// 		return 32
// 	case "iq", "uq":
// 		return 64
// 	case "p16_16":
// 		return 32
// 	case "if", "p16_32":
// 		return 48
// 	}
// 	panic("invalid code path")
// }
// // Get size of a relative displacement [in bits].
// rel_size :: proc(s: string) -> int {
// 	switch (s) {
// 	case "rel8":
// 		return 8
// 	case "rel16":
// 		return 16
// 	case "rel32":
// 		return 32
// 	}
// 	panic("invalid code path")
// }

// parse_operands :: proc(s: string, operands: ^[dynamic]Operand, allocator := context.temp_allocator) {
// 	context.temp_allocator = allocator // TODO: i think i need perm allocs for strings...
// 	t := init_tokenizer(s)
// 	scan_tokens(&t)
// 	p := Parser{t.tokens, 0}
// 	// for token in t.tokens {
// 	// 	fmt.printf("%v(%v) ", token.kind, token.text)
// 	// }
// 	// fmt.print("\n")
// 	i := 0
// 	for {
// 		op := parse_operand(&p)
// 		// fmt.println(op)
// 		append(operands, op)
// 		//
// 		peek := parser_peek(&p).kind
// 		if peek == .Comma {
// 			parser_consume(&p)
// 		} else if peek == .EOF {
// 			break
// 		}
// 	}
// }
// parse_operand :: proc(p: ^Parser) -> Operand {
// 	op := Operand{}
// 	flags: Operand_Flags
// 	// while next-token!= comma or eof
// 	for parser_peek(p).kind != .EOF && parser_peek(p).kind != .Comma {
// 		token := parser_consume(p)
// 		//
// 		// fmt.println("---FOR:", token.kind, token.text)
// 		#partial switch token.kind {
// 		case .Ident:
// 			switch token.text {
// 			case "tmm":
// 				op.tmm = true
// 				continue
// 			case "xmm":
// 				op.xmm = true
// 				continue
// 			case "ymm":
// 				op.ymm = true
// 				continue
// 			case "zmm":
// 				op.zmm = true
// 				continue
// 			}
// 			ta := transmute([]u8)token.text
// 			if ta[0] == 'b' {
// 				op.b = token.text
// 				continue
// 			} else if ta[0] == 'v' && ta[1] == 'm' {
// 				op.vm = token.text
// 				continue
// 			}
// 			if parse_op_rwx(p, &op, token) do continue
// 			if parse_op_fp(p, &op, token) do continue // st(i) or st(3)
// 			parse_op_rm(p, &op, token) // r64/m64
// 		case .Colon:
// 			peek := parser_peek(p)
// 			if peek.kind == .Ident {
// 				parse_op_meta(p, &op, token)
// 			} else {
// 				fmt.println("<!> UNHANDLED", token, peek)
// 			}
// 		case .Tilde:
// 			op.flags += {.Commutative}
// 		case .Plus:
// 			parse_op_offset(p, &op, token) // zmm+3
// 		case .Open_Angle_Bracket:
// 			op.flags += {.Optional}
// 		// case .Close_Angle_Bracket: // NOP
// 		case .Open_Brace:
// 			parse_op_avx_flags(p, &op, token) // {kz}
// 		// case .Close_Brace: //NOP
// 		case .Open_Bracket:
// 			parse_op_bit_range(p, &op, token)
// 		case .Slash:
// 		//parse_alt(p) 
// 		}
// 	}
// 	return op
// }
// parse_op_offset :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	token := parser_consume(p) // replace Plus with Number
// 	if token.kind != .Number {
// 		fmt.println(p.tokens[p.current - 2].text, p.tokens[p.current - 1].text, token.text)
// 	}
// 	assert(token.kind == .Number)
// 	op.offset = strconv.atoi(token.text)
// 	return true
// }
// parse_op_avx_flags :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	token := parser_consume(p) // replace Curly with ident
// 	assert(token.kind == .Ident)
// 	op.avx_flags = token.text
// 	parser_consume(p) // consume closing curly
// 	return true
// }
// parse_op_meta :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	token := parser_consume(p) // replace colon with ident
// 	assert(token.kind == .Ident)
// 	op.meta = token.text
// 	return true
// }
// parse_op_bit_range :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	assert(token.kind == .Open_Bracket)
// 	token := parser_consume(p)
// 	assert(token.kind == .Number)
// 	start := strconv.atoi(token.text)
// 	token = parser_consume(p)
// 	assert(token.kind == .Colon)
// 	token = parser_consume(p)
// 	assert(token.kind == .Number)
// 	end := strconv.atoi(token.text)
// 	token = parser_consume(p)
// 	assert(token.kind == .Close_Bracket)
// 	// fmt.println(start, end)
// 	op.bit_range = {start, end}
// 	op.flags += {.RegisterSlice}
// 	return true
// }
// parse_op_fp :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	if token.kind != .Ident || token.text != "st" {
// 		return false
// 	}
// 	token := parser_consume(p)
// 	assert(token.kind == .Open_Paren)
// 	token = parser_consume(p)
// 	assert(token.kind == .Number || token.kind == .Ident)
// 	if token.kind == .Number {
// 		op.fpu_index = strconv.atoi(token.text)
// 	}
// 	op.flags += {.FPU_ST}
// 	token = parser_consume(p)
// 	assert(token.kind == .Close_Paren)
// 	return true
// }
// parse_op_rm :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	//
// 	letters := token.text
// 	number: int = -1
// 	found_any, first, last := find_number_indices(letters)

// 	if found_any {
// 		number = strconv.atoi(letters[first:])
// 		letters = letters[:first]
// 	}
// 	if is_mem_op(letters) {
// 		op.mem = token.text
// 	} else if is_imm_op(letters) {
// 		op.imm = token.text
// 	} else if is_reg_op(letters) {
// 		op.reg = token.text
// 	} else if is_rel_op(letters) {
// 		op.rel = token.text
// 	} else {
// 		fmt.println("UNKNOWN RM:", letters, number, token)
// 	}
// 	return false
// }
// parse_op_rwx :: proc(p: ^Parser, op: ^Operand, token: Token) -> bool {
// 	colon := parser_peek(p)
// 	if colon.kind != .Colon || token.kind != .Ident {
// 		return false
// 	}
// 	char: u8 = token.text[0]
// 	is_rwx := true
// 	switch char {
// 	case 'R':
// 		op.flags = {.ReadAccess, .ImplicitZeroExtend}
// 	case 'r':
// 		op.flags = {.ReadAccess}
// 	case 'W':
// 		op.flags = {.WriteAccess, .ImplicitZeroExtend}
// 	case 'w':
// 		op.flags = {.WriteAccess}
// 	case 'X':
// 		op.flags = {.ReadAccess, .WriteAccess, .ImplicitZeroExtend}
// 	case 'x':
// 		op.flags = {.ReadAccess, .WriteAccess}
// 	case:
// 		is_rwx = false
// 	}
// 	if is_rwx {
// 		parser_consume(p) // eat the colon
// 		// fmt.println("eat tok",tok)
// 	}
// 	return is_rwx
// }

// // rel_op :: /^rel\d+$/
// is_rel_op :: proc(s: string) -> bool {
// 	if len(s) < 3 {return false} else if s[:3] == "rel" {return true}
// 	return false
// }
// // Uses Map
// is_reg_op :: proc(s: string) -> bool {
// 	sa := transmute([]u8)s
// 	if len(sa) == 0 {return false}
// 	if sa[0] == 'r' {return true}
// 	return false
// }
// // imm_op :: /^(?:1|i4|u4|ib|ub|iw|uw|id|ud|if|iq|uq|p16_16|p16_32)$/
// is_imm_op :: proc(s: string) -> bool {
// 	sa := transmute([]u8)s
// 	if len(sa) == 0 {return false}
// 	if sa[0] != '1' && sa[0] != 'i' && sa[0] != 'u' && sa[0] != 'p' {return false}
// 	return true
// }
// // mem_op :: /^(?:mem|mib|tmem|(?:m(?:off)?\d+(?:dec|bcd|fp|int)?)|(?:m16_\d+)|(?:vm\d+(?:x|y|z)))$/
// is_mem_op :: proc(s: string) -> bool {
// 	sa := transmute([]u8)s
// 	if len(sa) == 0 {return false}
// 	if sa[0] != 'm' && sa[0] != 't' && sa[0] != 'v' {return false}
// 	//
// 	has_nums, n_first, n_last := find_number_indices(s)
// 	// m80dec, m80bcd, moff64, m16int, m32fp, m16_16, vm32x
// 	switch sa[0] {
// 	case 't':
// 		// tmem
// 		if string(sa[1:]) == "mem" do return true
// 	case 'v':
// 		// vm\d+(?:x|y|z)
// 		if string(sa[1:1]) == "m" do return true // todo: better process...
// 	case 'm':
// 		// mem|mib|m(?:off)?\d+(?:dec|bcd|fp|int)?|(?:m16_\d+)
// 		return true
// 	}

// 	return false
// }
