package ojitsu
import "core:fmt"
import "core:testing"

test_constant32 :: proc(v: i32) {
	buf := get_os_memory()
	defer free_os_memory(buf)
	u := (transmute([4]u8)v) // must pass 4 bytes!!!
	offset: int = 0
	offset += write_slice(buf, offset, {0x48, 0xC7, 0xC0}) // mov rax, imm
	offset += write_slice(buf, offset, u[:]) // mov rax, imm
	offset += write_slice(buf, offset, {0xC3}) // ret
	protect_os_memory(buf)
	fn_ptr := transmute(proc() -> i32)buf
	disp_buf(buf, offset)
	res := fn_ptr()
	assert(v == res, "test_constant")
}
test_identity :: proc(v: i64) {
	buf := get_os_memory()
	defer free_os_memory(buf)
	offset: int = 0
	offset += write_slice(buf, offset, {0x48, 0x89, 0xC8}) // mov rax, rcx
	offset += write_slice(buf, offset, {0xC3}) // ret
	protect_os_memory(buf)
	fn_ptr := transmute(proc(v: i64) -> i64)buf
	disp_buf(buf, offset)
	res := fn_ptr(42)
	assert(v == res, "test_identity")
}
test_add_stack_const :: proc(v: i64) {
	buf := get_os_memory()
	defer free_os_memory(buf)
	offset: int = 0
	// offset = write_slice(buf, offset, {0x48, 0x89, 0xe5}) // mov rbp,rsp ::: 48 89 E5 
	offset += write_slice(buf, offset, {0x48, 0x83, 0xEC, 0x18}) // sub rsp, 24 ::: 48 83 EC 18

	offset += write_slice(buf, offset, {0xC7, 0x44, 0x24, 0x08, 0x02, 0x00, 0x00, 0x00}) // mov DWORD PTR [rsp],0x2 ::: c7 44 24 08 , 02 00 00 00

	offset += write_slice(buf, offset, {0x48, 0x89, 0xC8}) // mov rax, rcx

	offset += write_slice(buf, offset, {0x03, 0x44, 0x24, 0x00}) // add eax,DWORD PTR [rsp+0] ::: 03 44 24 00

	offset += write_slice(buf, offset, {0x48, 0x83, 0xC4, 0x18}) // add rsp, 24 ::: 48 83 c4 18

	offset += write_slice(buf, offset, {0xC3}) // ret
	protect_os_memory(buf)
	fn := transmute(proc(x: i64) -> i64)buf

	res := fn(v)
	fmt.printf("v:%v == res:%v\n", v, res)
	disp_buf(buf, offset)

}
test_ :: proc() {
	// 
}

write_slice :: proc(buf: [^]u8, offset: int, slice: []u8) -> int {
	for b, i in slice {
		buf[offset + i] = b
	}
	return len(slice)
}
@(test)
run_tests :: proc(t: ^testing.T) {
	// test_constant32(42) // mov rax, imm32; ret
	// test_identity(42) // mov rax,rcx
	test_add_stack_const(42)
}

disp_buf :: proc(buf: [^]u8, offset: int) {
	fmt.printf("Instruction-Stream: (%v) [", offset)
	for i := 0; i < offset; i += 1 {
		fmt.printf("%X", buf[i])
		if i < offset - 1 do fmt.printf(" ")
	}
	fmt.printf("]\n")
}

OperandKind2 :: enum {
	None,
	Register,
}
Register2 :: struct {
	idx: u8,
}

Operand2 :: struct {
	kind:    OperandKind2,
	using _: struct #raw_union {
		reg: Register2,
	},
}
eax :: Register2{0b000}
ecx :: Register2{0b001}
edx :: Register2{0b010}
ebx :: Register2{0b011}
esp :: Register2{0b100}
ebp :: Register2{0b101}
esi :: Register2{0b110}
edi :: Register2{0b111}
