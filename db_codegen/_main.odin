package ojitsu_parser
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:encoding/json"
import ojitsu "../"

Arch :: ojitsu.Arch
ArchFlag :: ojitsu.ArchFlag
Prefixes :: ojitsu.Prefixes
Prefix_Flag :: ojitsu.Prefix_Flag
OperandFlag :: ojitsu.OperandFlag

Instruction :: struct {
	arch:            Arch,
	prefixes:        Prefixes,
	vector_encoding: VectorFlags, // eg: VEX.LZ.66.0F38.W1
	opcode:          [dynamic]u8,
	tmp_operands:    [dynamic]OperandFlag,
	//TEMP:
	instr_str:       string,
	opcode_str:      string,
}

ADD :: #load("./json/ADD.json")

main :: proc() {
	json_data, err := json.parse(ADD)
	json_obj := json_data.(json.Object)
	//
	mnemonic := json_obj["mnemonic"].(json.String) // strings.to_lower(
	instances := json_obj["instructions"].(json.Array)
	op_encoding := json_obj["op_en"].(json.Object)
	//
	for i_val in instances {
		instr := i_val.(json.Object)
		instruction := parse_instruction(mnemonic, &instr, &op_encoding)
		fmt.println(instruction)
	}
}

parse_instruction :: proc(mnemonic: string, instr: ^json.Object, encodings: ^json.Object, allocator := context.allocator) -> Instruction {
	context.allocator = allocator
	instruction := Instruction{}
	if instr["x64"].(json.Boolean) {instruction.arch += {.x64}}
	if instr["x86"].(json.Boolean) {instruction.arch += {.x86}}
	//
	i := instr["instr"].(json.String)
	op := instr["opcode"].(json.String)
	instruction.instr_str = i // temp
	instruction.opcode_str = op // temp
	//
	parse_opcode(op, &instruction)
	//
	en_key := instr["op_en"].(json.String) // todo: test for this prior to blind access
	encoding := encodings[en_key].(json.Object)
	//
	return instruction
}

parse_opcode :: proc(s: string, instr: ^Instruction, allocator := context.allocator) {
	context.allocator = allocator
	t := init_tokenizer(s)
	scan_tokens(&t)
	p := Parser{t.tokens, 0}
	beyond_hex := false
	for parser_peek(&p).kind != .EOF {
		token := parser_consume(&p)
		#partial switch token.kind {
		case .Number:
			if !beyond_hex {if parse_hex_and_prefix(&p, instr, token) {continue}}
		case .Ident:
			if parse_opcode_vector(&p, instr, token) {continue}
			if parse_opcode_rex(&p, instr, token) {continue}
			// Note: `cb` & `cd` would parse as hex, so we do ci first
			if parse_opcode_ci(&p, instr, token) {
				beyond_hex = true
				continue
			}
			if !beyond_hex {if parse_hex_and_prefix(&p, instr, token) {continue}}
		case .Slash:
			// parse_opcode_slash(&p, token)
			beyond_hex = true
			if parser_peek(&p).kind == .Number {
				// /digit 
				// A digit between 0 and 7 indicates that the ModR/M byte of the instruction uses only the r/m (register or memory) operand. 
				// The reg field contains the digit that provides an extension to the instruction's opcode.
				n := parser_consume(&p)
				slash_digit := u8(strconv.atoi(n.text))
			} else {
				// Indicates that the ModR/M byte of the instruction contains both a register operand and an r/m operand.
				r := parser_consume(&p)
				if r.text == "is4" {
					is4 := true
					panic("not connected atm")
					//continue
				}
				assert(r.text == "r")
				slash_r := true
			}
		case .Plus:
			// TODO: seems like these are doing same thing..?
			if parser_peek(&p).kind == .Number {
				// fpu
				// A number used in floating-point instructions when one of the operands is ST(i) from the FPU register stack.
				// The number i (which can range from 0 to 7) is added to the hexadecimal byte given at the left of the plus 
				// sign to form a single opcode byte.
				n := parser_consume(&p)
				sti := u8(strconv.atoi(n.text))
			} else {
				// +rb, +rw, +rd
				// A register code, from 0 through 7, added to the hexadecimal byte given at the left of the plus sign to form 
				// a single opcode byte. The register codes are given in Table 3-1.
				r := parser_consume(&p).text
				ra := transmute([]u8)r
				if ra[0] == 'i' {
					st_is_i := true
					continue
				}
				assert(ra[0] == 'r')
				assert(len(ra) <= 2)
				c: u8 = 0
				if len(ra) == 2 {
					switch ra[1] {
					case 'b':
						c = 1
					case 'w':
						c = 2
					case 'd':
						c = 4
					}
				}
				reg_code := c
			}
		}
	}
}
parse_hex_and_prefix :: proc(p: ^Parser, instr: ^Instruction, token: Token) -> bool {
	if ok, hex := parse_hex(p, token); ok {
		p := into_prefix(hex)
		if p != .None {instr.prefixes += {p}} else {append(&instr.opcode, hex)}
		return true
	}
	return false
}
parse_hex :: proc(p: ^Parser, token: Token) -> (success: bool, hex: u8) {
	// fmt.println("PARSE-HEX", token.text)
	sa := transmute([]u8)token.text
	// todo: Collapse into one loop with early return
	for c in sa {
		not_digit := c < '0' || c > '9'
		not_hex_lower := (c < 'a' || c > 'f')
		not_hex_upper := (c < 'A' || c > 'F')
		if not_digit && not_hex_lower && not_hex_upper {return false, 0}
	}
	if len(sa) > 2 {
		fmt.println("<!>unhandled", token.text)
		// TODO: Do a for-Rev loop to handle general case
	} else if len(sa) == 2 {
		hex += u8(hex_to_int(sa[0])) << 4
		hex += u8(hex_to_int(sa[1])) << 0
	} else {
		hex += u8(hex_to_int(sa[0])) << 0
	}
	return true, hex
}
parse_opcode_vector :: proc(p: ^Parser, instr: ^Instruction, token: Token) -> bool {
	if parser_peek(p).kind != .Period {return false}
	if token.text != "VEX" && token.text != "EVEX" && token.text != "XOP" {return false}
	instr.vector_encoding = {}
	f := text_to_vectorflag(token.text)
	assert(f != .Invalid)
	instr.vector_encoding += {f}
	//
	parser_consume(p) // eat period
	v: Token = parser_consume(p)
	for {
		assert(v.kind == .Ident || v.kind == .Number)
		f := text_to_vectorflag(v.text)
		assert(f != .Invalid)
		instr.vector_encoding += {f}
		//
		next := parser_peek(p)
		if next.kind == .Period {
			parser_consume(p)
			v = parser_consume(p)
		} else {
			break
		}
	}
	return true
}
text_to_vectorflag :: proc(text: string) -> VectorFlag {
		//odinfmt: disable
		f := VectorFlag.Invalid
		switch text {
		case "VEX": f = .VEX
		case "EVEX": f = .EVEX
		case "XOP": f = .XOP
		//
		case "128": f = .Size_128
		case "256": f = .Size_256
		case "512": f = .Size_512
		//
		case "L0": f = .L0
		case "L1": f = .L1
		case "LZ": f = .LZ
		case "LIG": f = .LIG
		//
		case "0F": f = .Implied_0F
		case "0F38": f = .Implied_0F38
		case "0F3A": f = .Implied_0F3A
		case "NP": f = .NP
		//
		case "MAP5": f = .MAP5
		case "MAP6": f = .MAP6
		//
		case "66": f = .Implied_66
		case "F2": f = .Implied_F2
		case "F3": f = .Implied_F3
		//
		case "WIG": f = .WIG
		case "W0": f = .W0
		case "W1": f = .W1
		//
		case "M08": f = .M08
		case "M09": f = .M08
		case "M0A": f = .M0A
		case "P0": f = .P0
		case: fmt.println("text_to_vectorflag UNHANDLED", text)
		}
		return f
		//odinfmt: enable
}
hex_to_int :: proc(c: byte) -> int {
	switch c {
	case '0' ..= '9':
		return int(c - '0')
	case 'a' ..= 'f':
		return int(c - 'a') + 10
	case 'A' ..= 'F':
		return int(c - 'A') + 10
	}
	return -1
}
parse_opcode_rex :: proc(p: ^Parser, instr: ^Instruction, token: Token) -> bool {
	if token.text != "REX" {return false}
	instr.prefixes += {.REX_Enable}
	if parser_peek(p).kind == .Period {
		parser_consume(p)
		w := parser_consume(p)
		assert(w.kind == .Ident && w.text == "W")
		instr.prefixes += {.REX_W}
	}
	if parser_peek(p).kind == .Plus {parser_consume(p)} 	// rex '+' needs no action
	return true
}
parse_opcode_ci :: proc(p: ^Parser, instr: ^Instruction, token: Token) -> bool {
	sa := transmute([]u8)token.text
	if sa[0] != 'c' && sa[0] != 'i' {return false}
	size := u8_to_size(sa[1])
	if sa[0] == 'c' do panic("not impl") // TODO: this
	switch size {
	case 1:
		append(&instr.tmp_operands, OperandFlag.imm8)
	case 2:
		append(&instr.tmp_operands, OperandFlag.imm16)
	case 4:
		append(&instr.tmp_operands, OperandFlag.imm32)
	case 8:
		append(&instr.tmp_operands, OperandFlag.imm64)
	}
	return true
}
u8_to_size :: proc(char: u8) -> u8 {
	size: u8 = 0
	switch char {
	case 'b':
		size = 1
	case 'w':
		size = 2
	case 'd':
		size = 4
	case 'q':
		size = 8
	case:
		panic("unhandled")
	}
	return size
}
into_prefix :: proc(hex: u8) -> Prefix_Flag {
	if hex == 0x2E || hex == 0x3E do panic("who has this?")
	//odinfmt: disable
	switch hex {
	case 0x0F: return .Lock
	case 0x66: return .OpSizeOverride
	// case 0xF2: return .BND
	case 0xF2: return .REPNZ // <---
	case 0xF3: return .REP
	case 0x2E: return .CS_Override // <---
	case 0x36: return .SS_Override
	case 0x3E: return .DS_Override // <---
	case 0x26: return .ES_Override
	case 0x64: return .FS_Override
	case 0x65: return .GS_Override
	// case 0x2E: return .BranchNotTaken
	// case 0x3E: return .BranchTaken
	case 0x67: return .AddressSizeOverride
	case: return .None
	}
	//odinfmt: enable
}
