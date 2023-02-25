package ojit
// import win32 "core:sys/windows"
// import "core:fmt"
// PAGE_SIZE :: 4096

// // Intel ISR: https://www.cs.cmu.edu/~410/doc/intel-isr.pdf
// // Demo of simple C Asm JIT: https://nullprogram.com/blog/2015/03/19/
// // ASMJIT Docs: https://asmjit.com/doc/group__asmjit__core.html

// main :: proc() {
// 	a := Assembler{}

// 	first_param: GP // https://en.wikipedia.org/wiki/X86_calling_conventions#x86-64_calling_conventions
// 	when ODIN_OS == .Windows {
// 		first_param = .CX
// 	} else when ODIN_OS == .Linux {
// 		first_param = .DI
// 	}

// 	mov(&a, .AX, first_param)
// 	add(&a, .AX, .AX)
// 	ret(&a)

// 	doubler := transmute(proc(x: int) -> int)assemble(&a)
// 	result := doubler(42)
// 	fmt.println("Result:", result)
// 	asm_free(&a)
// }

// Mod :: enum u8 {
// 	Deref        = 0x00,
// 	Deref_Disp8  = 0x01,
// 	Deref_Disp32 = 0x02,
// 	Register     = 0x03,
// }

// GP :: enum u8 {
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
// // casts: lo:8bit, hi:8bit, upper of 16, w:16,d:32,q:64

// mod_rm_byte :: proc(mod: Mod, src: GP, dst: GP) -> u8 {
// 	return u8(mod) << 6 | u8(dst) << 3 | u8(src)
// }

// Assembler :: struct {
// 	buf: [dynamic]u8, // TODO: directly alloc into VirtualAlloc rather than copy?
// }
// mov :: proc(a: ^Assembler, dst: GP, src: GP) {
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
// 	platform_buf: [^]u8

// 	when ODIN_OS == .Windows {
// 		platform_buf =
// 		transmute([^]u8)win32.VirtualAlloc(
// 			nil,
// 			uint(PAGE_SIZE),
// 			win32.MEM_RESERVE | win32.MEM_COMMIT,
// 			win32.PAGE_READWRITE,
// 		)
// 	} else when ODIN_OS == .Linux {
// 		// int prot = PROT_READ | PROT_WRITE;
// 		// int flags = MAP_ANONYMOUS | MAP_PRIVATE;
// 		// return mmap(NULL, PAGE_SIZE, prot, flags, -1, 0);
// 	}
// 	//
// 	for b, i in a.buf {
// 		platform_buf[i] = b
// 	}
// 	fmt.print("Instruction stream: [")
// 	for b, i in a.buf {
// 		fmt.printf("%X", b)
// 		if i < len(a.buf) - 1 do fmt.print(", ")
// 	}
// 	fmt.print("]\n")
// 	//
// 	when ODIN_OS == .Windows {
// 		old: win32.DWORD
// 		win32.VirtualProtect(platform_buf, PAGE_SIZE, win32.PAGE_EXECUTE_READ, &old)
// 	} else when ODIN_OS == .Linux {
// 		// mprotect(buf, sizeof(*buf), PROT_READ | PROT_EXEC);
// 	}

// 	delete(a.buf)
// 	return platform_buf
// }

// asm_free :: proc(a: ^Assembler) {
// 	when ODIN_OS == .Windows {
// 		win32.VirtualFree(a, 0, win32.MEM_RELEASE)
// 	} else when ODIN_OS == .Linux {
// 		// munmap(buf, PAGE_SIZE)
// 	}
// }
