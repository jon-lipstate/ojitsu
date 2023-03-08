package ojitsu_parser
import "core:fmt"
import "core:strings"
import "core:strconv"
import "core:encoding/json"
import ojitsu "../"
Instruction_ISR :: ojitsu.Instruction_ISR
Arch :: ojitsu.Arch
ArchFlag :: ojitsu.ArchFlag
LegacyPrefixes :: ojitsu.LegacyPrefixes
VectorPrefix :: ojitsu.VectorPrefix
VectorFlag :: ojitsu.VectorFlag
REX :: ojitsu.REX
LegacyPrefixFlag :: ojitsu.LegacyPrefixFlag
OperandKind :: ojitsu.OperandKind
Size :: ojitsu.Size

Mode :: bit_set[ModeFlag]
ModeFlag :: enum {
	//Legacy
	Real,
	Protected,
	Virtual8086,
	// Long
	Compatibility,
	X64,
}

add_mini :: #load("./xed/mini.json")

main :: proc() {
	json_data, err := json.parse(add_mini)
	entries := json_data.(json.Array)
	for e_val in entries {
		entry := e_val.(json.Object)
		instruction := parse_xed(&entry)
		// fmt.println(instruction)
		break
	}
}

parse_xed :: proc(obj: ^json.Object) -> ojitsu.Instruction_ISR {
	pattern := obj["PATTERN"].(json.String)
	parse_pattern("0xAB mode64 norexw_prefix 66_prefix  norep")
	fmt.println()
	fmt.println(pattern)

	return {}
}
parse_pattern :: proc(s: string) {
	t := init_tokenizer(s)
	scan_tokens(&t)
	p := Parser{t.tokens, 0}
	for parser_peek(&p).kind != .EOF {
		token := parser_consume(&p)
		//fmt.println("--->", token.kind, token.text)
		#partial switch token.kind {
		case .Number:
			if parse_prefix66(&p, token) do continue
			fmt.println("# ::", token.text)
		case .Ident:
			if parse_assignment(&p, token) do continue
			if parse_fn(&p, token) do continue
			if parse_braced(&p, token, "MOD") do continue
			if parse_braced(&p, token, "REG") do continue
			if parse_braced(&p, token, "RM") do continue
			if parse_braced(&p, token, "SRM") do continue // source register specifier field.
			// general attr ident:
			fmt.println("IDENT::", token.text)
		case .Bang, .Equals:
		}
	}
}
parse_prefix66 :: proc(p: ^Parser, token: Token) -> bool {
	next := parser_peek(p)
	if token.text != "66" || next.text != "_prefix" do return false
	parser_consume(p)
	fmt.println("Prefix66!")
	return true
}
parse_assignment :: proc(p: ^Parser, token: Token) -> bool {
	next := parser_peek(p).kind
	if next != .Bang && next != .Equals do return false
	ne := next == .Bang

	parser_consume(p) // =
	// if ne do parser_consume(p) // eat !
	label := token.text
	value := parser_consume(p)

	fmt.println(label, ne ? "!=" : "=", value.text)

	return true
}
parse_braced :: proc(p: ^Parser, token: Token, text: string) -> bool {
	if token.text != text do return false

	assert(parser_peek(p).kind == .Open_Bracket)
	parser_consume(p) // open [
	inside := parser_consume(p)
	parser_consume(p) //close ]
	if inside.kind == .Number {
		fmt.println(text, "[#] :: ", inside.text)
	} else {
		fmt.println(text, "[txt]", inside.text)
	}

	return true
}
parse_fn :: proc(p: ^Parser, token: Token) -> bool {
	next := parser_peek(p).kind
	next2 := parser_peek2(p).kind
	if next != .Open_Paren && next2 != .Close_Paren {
		return false
	}
	parser_consume(p) //()
	parser_consume(p)
	// TODO:
	fmt.println("FN", token.text)
	return true
}
parse_operands :: proc() {
	// Eat REGX=
	// if string((transmute([]u8)token.text)[:3]) == "REG" && parser_peek(&p).kind == .Equals {
	// 	parser_consume(&p)
	// 	continue
	// }
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
into_prefix :: proc(hex: u8) -> LegacyPrefixFlag {
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
