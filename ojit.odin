package ojit
// import win32 "core:sys/windows"
// import "core:mem"
// import "core:fmt"
// import "core:intrinsics"

// PAGE_SIZE :: 4096

// foreign import lib "./njit.obj"
// @(default_calling_convention = "c")
// foreign lib {
// 	sum4i :: proc(a, b, c, d: i64) -> i64 ---
// 	sum4f :: proc(a, b, c, d: f64) -> f64 ---
// }
// MOV: opcode: instr:         Desc: 
// MOV: 89 /r,  MOV r/m32,r32, Move r32 to r/m32
// Reg Order: `ax, cx, dx, bx, sp, bp, si, di`
// 89 {11 000 001 == C1}
// insert(ab,2, 0x89_c1)          // mov %rcx, %rax
// // insert(ab,4, 0x8B_44_24_08)          // mov %rdi, %rax
// insert(ab,1, 0xC3)          // ret
// mov rax,rcx
// fmt.println("Call sum")
// r:= sum4i(1,1,1,1)
// f:= sum4f(1.25,1.25,1.25,1)
// fmt.println("Result:",r,f)

// mainn :: proc() {
// 	a := Assembler{}
// 	mov(&a, .AX, .CX)
// 	add(&a, .AX, .AX)
// 	ret(&a)
// 	doubler := transmute(proc(x: int) -> int)assemble(&a)
// 	result := doubler(42)
// 	fmt.println("Result:", result)
// }

// fMod :: enum u8 {
// 	Deref        = 0x0,
// 	Deref_Disp8  = 0x01,
// 	Deref_Disp32 = 0x02,
// 	Register     = 0x03,
// }

// fGP :: enum u8 {
// 	AX  = 0x00, // AL|AH|AX|EAX|RAX
// 	CX  = 0x01, // CL|CH|CX|ECX|RCX
// 	DX  = 0x02, // DL|DH|DX|EDX|RDX
// 	BX  = 0x03, // BL|BH|BX|EBX|RBX
// 	SP  = 0x04, // SPL|SP|ESP|RSP
// 	BP  = 0x05, // BPL|BP|EBP|RBP
// 	SI  = 0x06, // SIL|SI|ESI|RSI
// 	DI  = 0x07, // DIL|DI|EDI|RDI
// 	R8  = 0x08, // R8B|R8W|R8D|R8 registers (64-bit only)
// 	R9  = 0x09, // R9B|R9W|R9D|R9 registers (64-bit only)
// 	R10 = 0x0A, // R10B|R10W|R10D|R10 registers (64-bit only)
// 	R11 = 0x0B, // R11B|R11W|R11D|R11 registers (64-bit only)
// 	R12 = 0x0C, // R12B|R12W|R12D|R12 registers (64-bit only)
// 	R13 = 0x0D, // R13B|R13W|R13D|R13 registers (64-bit only)
// 	R14 = 0x0E, // R14B|R14W|R14D|R14 registers (64-bit only)
// 	R15 = 0x0F, // R15B|R15W|R15D|R15 registers (64-bit only)
// }
// casts: lo:8bit, hi:8bit, upper of 16, w:16,d:32,q:64
// Reg :: struct {
// 	group:   u8,
// 	type_id: u8,
// }
// VectorRegister :: enum u8 {
// 	XMM0 = 0x00,
// 	XMM1 = 0x01,
// 	XMM2 = 0x02,
// 	XMM3 = 0x03,
// 	XMM4 = 0x04,
// 	XMM5 = 0x05,
// 	XMM6 = 0x06,
// 	XMM7 = 0x07,
// }
// Register :: union {
// 	GP,
// 	VectorRegister,
// }

// fmod_rm_byte :: proc(mod: Mod, src: GP, dst: GP) -> u8 {
// 	return u8(mod) << 6 | u8(dst) << 3 | u8(src)
// }


// fAssembler :: struct {
// 	buf: [dynamic]u8,
// }
// mov :: proc(a: ^Assembler, dst: GP, src: GP) {
// 	// append(&a.buf, 0x48)
// 	append(&a.buf, 0x89)
// 	append(&a.buf, mod_rm_byte(.Register, dst, src))
// }
// add :: proc(a: ^Assembler, dst: GP, src: GP) {
// 	append(&a.buf, 0x01)
// 	append(&a.buf, mod_rm_byte(.Register, dst, src))
// }
// ret :: proc(a: ^Assembler) {
// 	append(&a.buf, 0xC3)
// }
// assemble :: proc(a: ^Assembler) -> rawptr {
// 	platform_buf := transmute([^]u8)win32.VirtualAlloc(
// 		nil,
// 		uint(PAGE_SIZE),
// 		win32.MEM_RESERVE | win32.MEM_COMMIT,
// 		win32.PAGE_READWRITE,
// 	)
// 	for b, i in a.buf {
// 		platform_buf[i] = b
// 	}
// 	fmt.print("Instruction stream: [")
// 	for b, i in a.buf {
// 		fmt.printf("%X", b)
// 		if i < len(a.buf) - 1 do fmt.print(", ")
// 	}
// 	fmt.print("]\n")


// 	old: win32.DWORD
// 	win32.VirtualProtect(platform_buf, PAGE_SIZE, win32.PAGE_EXECUTE_READ, &old)
// 	delete(a.buf)
// 	return platform_buf
// }
