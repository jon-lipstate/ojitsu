package ojitsu_parser
import "core:fmt"
import "core:strings"
import "core:strconv"
//
find_number_indices :: proc(s: string) -> (found_any: bool, first: int, last: int) {
	found_any = false
	first = -1
	last = -1
	numbers := bit_set['0' ..= '9']{'0', '1', '2', '3', '4', '5', '6', '7', '8', '9'}
	sa := transmute([]u8)s
	for c, i in sa {
		if rune(c) in numbers {
			found_any = true
			if first == -1 {
				first = i
			} else {
				last = i
			}
		}
	}

	return found_any, first, last
}

parser_consume :: proc(p: ^Parser) -> Token {
	token := p.tokens[p.current]
	p.current += 1
	return token
}
parser_prev :: proc(p: ^Parser) -> Token {
	return p.tokens[p.current - 1]
}
parser_peek :: proc(p: ^Parser) -> Token {
	return p.tokens[p.current]
}
parser_peek2 :: proc(p: ^Parser) -> Token {
	if len(p.tokens) <= p.current + 1 {
		return p.tokens[len(p.tokens) - 1]
	}
	return p.tokens[p.current + 1]
}
Parser :: struct {
	tokens:  [dynamic]Token,
	current: int,
}
init_tokenizer :: proc(data: string) -> Tokenizer {
	t := Tokenizer {
		data   = transmute([]u8)data,
		offset = 0,
	}
	return t
}
scan_tokens :: proc(t: ^Tokenizer) {
	for !is_at_end(t) {
		scan_token(t)
	}
	append(&t.tokens, Token{kind = .EOF})
}
next :: proc(t: ^Tokenizer) -> u8 #no_bounds_check {
	if t.offset >= len(t.data) {
		t.r = 0x0
	} else {
		t.r = t.data[t.offset]
		t.offset += 1
	}
	return t.r
}
peek :: proc(t: ^Tokenizer) -> u8 #no_bounds_check {
	if t.offset >= len(t.data) {
		return 0x0
	} else {
		return t.data[t.offset]
	}
}
peek_next :: proc(t: ^Tokenizer) -> u8 #no_bounds_check {
	if t.offset >= len(t.data) + 1 {
		return 0x0
	} else {
		return t.data[t.offset + 1]
	}
}
scan_token :: proc(t: ^Tokenizer) {
	c := next(t)
	switch c {
	case '(':
		append(&t.tokens, Token{t.offset, .Open_Paren, "("})
	case ')':
		append(&t.tokens, Token{t.offset, .Close_Paren, ")"})
	case '{':
		append(&t.tokens, Token{t.offset, .Open_Brace, "{"})
	case '}':
		append(&t.tokens, Token{t.offset, .Close_Brace, "}"})
	case '[':
		append(&t.tokens, Token{t.offset, .Open_Bracket, "["})
	case ']':
		append(&t.tokens, Token{t.offset, .Close_Bracket, "]"})
	case '<':
		append(&t.tokens, Token{t.offset, .Open_Angle_Bracket, "<"})
	case '>':
		append(&t.tokens, Token{t.offset, .Close_Angle_Bracket, ">"})
	case ':':
		append(&t.tokens, Token{t.offset, .Colon, ":"})
	case '+':
		append(&t.tokens, Token{t.offset, .Plus, "+"})
	case '!':
		append(&t.tokens, Token{t.offset, .Bang, "!"})
	case '-':
		append(&t.tokens, Token{t.offset, .Minus, "-"})
	case '=':
		append(&t.tokens, Token{t.offset, .Equals, "="})
	case '~':
		append(&t.tokens, Token{t.offset, .Tilde, "~"})
	case '/':
		append(&t.tokens, Token{t.offset, .Slash, "/"})
	case ',':
		append(&t.tokens, Token{t.offset, .Comma, ","})
	case '.':
		append(&t.tokens, Token{t.offset, .Period, "."})
	case ' ': // nop
	case:
		next_c := peek(t)
		if c == '0' && next_c == 'x' {
			hex(t)
		} else if c == '0' && next_c == 'b' {
			binary(t)
		} else {
			next_is_alpha := is_alpha(peek(t)) // test for: {1tox} 
			c_is_digit := is_digit(c)
			if c_is_digit && next_is_alpha {
				ident(t)
			} else if is_digit(c) {
				number(t)
			} else if is_alpha(c) {
				ident(t)
			} else {
				fmt.printf("INVALID: '%v' (0x%X)\n", rune(c), c)
				panic("Invalid Token")
			}
		}

	}
}
is_at_end :: proc(t: ^Tokenizer) -> bool {
	return t.offset >= len(t.data)
}
hex :: proc(t: ^Tokenizer) {
	start := t.offset - 1
	if peek(t) == '0' do next(t)
	if peek(t) == 'x' do next(t)
	for is_hex_digit(peek(t)) do next(t)
	append(&t.tokens, Token{start, .Number, string(t.data[start:t.offset])})
}
binary :: proc(t: ^Tokenizer) {
	start := t.offset - 1
	if peek(t) == '0' do next(t)
	if peek(t) == 'b' do next(t)
	for is_binary_digit(peek(t)) do next(t)
	append(&t.tokens, Token{start, .Number, string(t.data[start:t.offset])})
}
number :: proc(t: ^Tokenizer) {
	start := t.offset - 1
	for is_digit(peek(t)) do next(t)
	append(&t.tokens, Token{start, .Number, string(t.data[start:t.offset])})
}
ident :: proc(t: ^Tokenizer) {
	start := t.offset - 1
	for is_alpha_numeric(peek(t)) do next(t)
	append(&t.tokens, Token{start, .Ident, string(t.data[start:t.offset])})
}

is_binary_digit :: proc(c: u8) -> bool {
	return c == '0' || c == '1' || c == '_'
}
is_hex_digit :: proc(c: u8) -> bool {
	is_digit := c >= '0' && c <= '9'
	is_hex_lower := (c >= 'a' && c <= 'f')
	is_hex_upper := (c >= 'A' && c <= 'F')
	return is_digit || is_hex_lower || is_hex_upper || c == '_'
}
is_digit :: proc(c: u8) -> bool {
	return c >= '0' && c <= '9'
}
is_alpha :: proc(c: u8) -> bool {
	return c >= 'a' && c <= 'z' || c >= 'A' && c <= 'Z' || c == '_'
}
is_alpha_numeric :: proc(c: u8) -> bool {
	return is_alpha(c) || is_digit(c)
}
Tokenizer :: struct {
	data:   []u8,
	offset: int,
	r:      u8,
	tokens: [dynamic]Token,
}
Token :: struct {
	offset: int,
	kind:   Token_Kind,
	text:   string,
}
Token_Kind :: enum {
	Invalid,
	Colon,
	Comma,
	Slash,
	Tilde,
	Plus,
	Bang,
	Minus,
	Equals,
	Period,
	Ident,
	Number,
	Open_Paren, // ()
	Close_Paren,
	Open_Brace, // {}
	Close_Brace,
	Open_Bracket, // []
	Close_Bracket,
	Open_Angle_Bracket, // <>
	Close_Angle_Bracket,
	EOF,
}
