package ojitsu
import "core:fmt"
import "core:testing"

test_constant :: proc(v: u8) {
	buf := get_os_memory()
	defer free_os_memory(buf)
	// fmt.printf("buf: %X\n", buf)
	offset: int = 0
	offset += write_slice(buf, offset, {0x48, 0xC7, 0xC0, v}) // mov rax, imm
	offset += write_slice(buf, offset, {0xC3}) // ret
	protect_os_memory(buf)
	// fmt.printf("prot: %X\n", buf)
	fn_ptr := transmute(proc() -> i32)buf
	//
	disp_buf(buf, offset)
	//
	res := fn_ptr()
	fmt.printf("test_constant - v:%v == res:%v", v, res)
	fmt.println("PASS")
}
test_identity :: proc(v: i32) {
	// mov rax,rcx
}
test_add_stack_const :: proc(v: i32) {
	buf := get_os_memory()
	defer free_os_memory(buf)
	offset: int = 0
	offset = write_slice(buf, offset, {0x48, 0x83, 0xEC, 0x18}) // sub rsp, 24 ::: 48 83 EC 18
	offset = write_slice(buf, offset, {0x48, 0x83, 0xEC, 0x18}) // sub rsp, 24 ::: 48 83 EC 18

	protect_os_memory(buf)
	fn := transmute(proc(x: i32) -> i32)buf

	res := fn(v)
	fmt.printf("v:%v == res:%v", v, res)

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
	test_constant(42)
}

disp_buf :: proc(buf: [^]u8, offset: int) {
	fmt.printf("Instruction-Stream: (%v) [", offset)
	for i := 0; i < offset; i += 1 {
		fmt.printf("%X", buf[i])
		if i < offset - 1 do fmt.printf(" ")
	}
	fmt.printf("]\n")
}
