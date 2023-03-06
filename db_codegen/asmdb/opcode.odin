package asmdb_parser
// import "core:fmt"
// import "core:strconv"
// import ojitsu "../../"

// OpCode :: struct {
// 	code:            [dynamic]u8,
// 	prefixes:        ojitsu.Prefixes, // includes rex
// 	ci:              [dynamic]string, // ordered list eg: ib iw
// 	vector_encoding: VectorFlags, // VEX.LZ.66.0F38.W1 splits on dots
// 	modrm_encoding:  u8,
// 	fpu_encoding:    u8,
// 	rm_digit:        u8, // /0 to /7
// 	mod_rm:          bool, // /r
// 	reg_code:        u8, // +rb (ASSUME +r=0..?)
// 	sti:             u8,
// 	st_is_i:         bool,
// 	is4:             bool,
// }

// parse_opcode :: proc(s: string, allocator := context.temp_allocator) -> OpCode {
// 	context.temp_allocator = allocator // TODO: i think i need perm allocs for strings...
// 	t := init_tokenizer(s)
// 	scan_tokens(&t)
// 	p := Parser{t.tokens, 0}
// 	opcode := OpCode{}
// 	beyond_hex := false
// 	for parser_peek(&p).kind != .EOF {
// 		token := parser_consume(&p)
// 		// fmt.println(token)
// 		//

// 		#partial switch token.kind {
// 		case .Number:
// 			if !beyond_hex {
// 				if ok, hex := parse_hex(&p, token); ok {
// 					// fmt.println("number", ok, hex)
// 					append(&opcode.code, hex)
// 				}
// 			}
// 		case .Ident:
// 			if parse_opcode_vector(&p, &opcode, token) {
// 				continue
// 			}
// 			if ok, rex := parse_opcode_rex(&p, token); ok {
// 				opcode.prefixes += {ojitsu.Prefix_Flag.REX_Enable}
// 				continue
// 			}
// 			// Note: `cb` & `cd` would parse as hex, so we do ci first
// 			if ok, ci := parse_opcode_ci(&p, token); ok {
// 				beyond_hex = true
// 				append(&opcode.ci, ci)
// 			}
// 			if !beyond_hex {
// 				if ok, hex := parse_hex(&p, token); ok {
// 					append(&opcode.code, hex)
// 				}
// 			}
// 		case .Slash:
// 			// parse_opcode_slash(&p, token)
// 			beyond_hex = true
// 			if parser_peek(&p).kind == .Number {
// 				// /digit 
// 				// A digit between 0 and 7 indicates that the ModR/M byte of the instruction uses only the r/m (register or memory) operand. 
// 				// The reg field contains the digit that provides an extension to the instruction's opcode.
// 				n := parser_consume(&p)
// 				opcode.rm_digit = u8(strconv.atoi(n.text))
// 			} else {
// 				// Indicates that the ModR/M byte of the instruction contains both a register operand and an r/m operand.
// 				r := parser_consume(&p)
// 				if r.text == "is4" {
// 					opcode.is4 = true
// 					continue
// 				}
// 				if r.text != "r" {
// 					fmt.println("---------", token.text, r)
// 				}
// 				assert(r.text == "r")
// 				opcode.mod_rm = true
// 			}
// 		case .Plus:
// 			// TODO: seems like these are doing same thing..?
// 			if parser_peek(&p).kind == .Number {
// 				// fpu
// 				// A number used in floating-point instructions when one of the operands is ST(i) from the FPU register stack.
// 				// The number i (which can range from 0 to 7) is added to the hexadecimal byte given at the left of the plus 
// 				// sign to form a single opcode byte.
// 				n := parser_consume(&p)
// 				opcode.sti = u8(strconv.atoi(n.text))
// 			} else {
// 				// +rb, +rw, +rd
// 				// A register code, from 0 through 7, added to the hexadecimal byte given at the left of the plus sign to form 
// 				// a single opcode byte. The register codes are given in Table 3-1.
// 				r := parser_consume(&p).text
// 				ra := transmute([]u8)r
// 				if ra[0] == 'i' {
// 					opcode.st_is_i = true
// 					continue
// 				}
// 				if ra[0] != 'r' {
// 					fmt.println(token.text, r)
// 				}
// 				assert(ra[0] == 'r')
// 				assert(len(ra) <= 2)
// 				c: u8 = 0
// 				if len(ra) == 2 {
// 					switch ra[1] {
// 					case 'b':
// 						c = 1
// 					case 'w':
// 						c = 2
// 					case 'd':
// 						c = 4
// 					}
// 				}
// 				opcode.reg_code = c
// 			}
// 		}
// 	}
// 	return opcode
// }
// parse_hex :: proc(p: ^Parser, token: Token) -> (success: bool, hex: u8) {
// 	// fmt.println("PARSE-HEX", token.text)
// 	sa := transmute([]u8)token.text
// 	// todo: Collapse into one loop with early return
// 	for c in sa {
// 		not_digit := c < '0' || c > '9'
// 		not_hex_lower := (c < 'a' || c > 'f')
// 		not_hex_upper := (c < 'A' || c > 'F')
// 		if not_digit && not_hex_lower && not_hex_upper {
// 			// fmt.println("NOT HEX", rune(c), not_hex_upper, c < 'A', c > 'F', token.text)
// 			return false, 0
// 		}
// 	}
// 	if len(sa) > 2 {
// 		fmt.println("<!>unhandled", token.text)
// 		// TODO: Reverse for loop to handle general case
// 	} else if len(sa) == 2 {
// 		hex += u8(hex_to_int(sa[0])) << 4
// 		hex += u8(hex_to_int(sa[1])) << 0
// 	} else {
// 		hex += u8(hex_to_int(sa[0])) << 0
// 	}
// 	return true, hex
// }
// parse_opcode_rex :: proc(p: ^Parser, token: Token) -> (success: bool, rex: bool) {
// 	// Always Hardcoded as REX.W :: Ident(REX) Period Ident(W)
// 	if token.text != "REX" {
// 		return false, false
// 	}
// 	next := parser_consume(p)
// 	assert(next.kind == .Period)
// 	parser_consume(p) // eat W
// 	return true, true
// }
// parse_opcode_ci :: proc(p: ^Parser, token: Token) -> (success: bool, ci: string) {
// 	sa := transmute([]u8)token.text
// 	if sa[0] != 'c' && sa[0] != 'i' {return false, ""}
// 	return true, token.text
// }
// parse_opcode_vector :: proc(p: ^Parser, opcode: ^OpCode, token: Token) -> bool {
// 	if parser_peek(p).kind != .Period {
// 		return false
// 	}
// 	opcode.vector_encoding = {}
// 	f := text_to_vectorflag(token.text)
// 	assert(f != .Invalid)
// 	opcode.vector_encoding += {f}
// 	//
// 	parser_consume(p) // eat period
// 	v: Token = parser_consume(p)
// 	for {
// 		assert(v.kind == .Ident || v.kind == .Number)
// 		f := text_to_vectorflag(v.text)
// 		assert(f != .Invalid)
// 		opcode.vector_encoding += {f}
// 		//
// 		next := parser_peek(p)
// 		if next.kind == .Period {
// 			parser_consume(p)
// 			v = parser_consume(p)
// 		} else {
// 			break
// 		}
// 	}
// 	return true
// }

// text_to_vectorflag :: proc(text: string) -> VectorFlag {
// 	//odinfmt: disable
// 	f := VectorFlag.Invalid
// 	switch text {
// 	case "VEX": f = .VEX
// 	case "EVEX": f = .EVEX
// 	case "XOP": f = .XOP
// 	//
// 	case "128": f = .Size_128
// 	case "256": f = .Size_256
// 	case "512": f = .Size_512
// 	//
// 	case "L0": f = .L0
// 	case "L1": f = .L1
// 	case "LZ": f = .LZ
// 	case "LIG": f = .LIG
// 	//
// 	case "0F": f = .Implied_0F
// 	case "0F38": f = .Implied_0F38
// 	case "0F3A": f = .Implied_0F3A
// 	case "NP": f = .NP
// 	//
// 	case "MAP5": f = .MAP5
// 	case "MAP6": f = .MAP6
// 	//
// 	case "66": f = .Implied_66
// 	case "F2": f = .Implied_F2
// 	case "F3": f = .Implied_F3
// 	//
// 	case "WIG": f = .WIG
// 	case "W0": f = .W0
// 	case "W1": f = .W1
// 	//
// 	case "M08": f = .M08
// 	case "M09": f = .M08
// 	case "M0A": f = .M0A
// 	case "P0": f = .P0
// 	case: fmt.println("text_to_vectorflag UNHANDLED", text)
// 	}
// 	return f
// 	//odinfmt: enable
// }

// hex_to_int :: proc(c: byte) -> int {
// 	switch c {
// 	case '0' ..= '9':
// 		return int(c - '0')
// 	case 'a' ..= 'f':
// 		return int(c - 'a') + 10
// 	case 'A' ..= 'F':
// 		return int(c - 'A') + 10
// 	}
// 	return -1
// }
