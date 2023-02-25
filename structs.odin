package ojit

main :: proc() {
	a := make_assembler()
	main := get_main_block(&a)
	rax := reg(.RAX) // fn queries bit-size for use in the mov switches
	rdi := reg(.RDI)
	mov(main, rax, reg(.RCX))
	mov(main, rdi, 0x0) // set loop counter to zero
	//
	loop := insert_label(&a) // TODO: does a label actually need a block? i am thinking no...
	add(loop, rax, rax) // double again
	add(loop, rdi, 0x1)
	cmp(loop, rdi, 0xA) // for 0..10
	jne(loop)
	//
	ret(main)
	//
	fn_ptr := transmute(proc(x: i64) -> i64)assemble(&a)
}
simple_example :: proc() {
	a := make_assembler()
	main := get_main_block(&a)
	rax := reg(.RAX) // fn gets bit-size
	rcx := reg(.RCX)
	mov(main, rax, reg(.RCX))
	// add(main, rax, rax)
	// ret(main)
	// fn_ptr:= transmute(proc(x:i64)->i64)assemble(&a)
}

// .data:
data :: proc(label: string, idk: any) {}

reg :: proc(r: GeneralPurpose) -> Reg {
	reg: Reg = {r, 0}
	set_register_size(&reg)
	return reg
}
set_register_size :: proc(r: ^Reg) {
	#partial switch r.reg {
	// todo: for reals
	case:
		r.bits = 64
	}
}
make_assembler :: proc(allocator := context.allocator) -> Asm {
	a := Asm{}
	// a.sections[".code"] = {} // Insert Code Section
	append(&a.blocks, Block{}) // Main Code Block
	return a
}
get_main_block :: proc(a: ^Asm) -> ^Block {
	return &a.blocks[0]
}
insert_label :: proc(a: ^Asm) -> ^Label {
	bidx := len(a.blocks)
	append(&a.blocks, Block{})
	lidx := len(a.labels)
	append(&a.labels, Label{&a.blocks[bidx]})
	return &a.labels[lidx]
}
Label :: struct {
	block: ^Block,
}
// Section :: [dynamic]Block // asmjit::Section* text = code.textSection();
Block :: struct {
	section: string,
	buf:     [dynamic]u8,
} // make Section union to Label? seems reasonable
Asm :: struct {
	blocks: [dynamic]Block, // TODO: replace this with main:Block & Label{name,code:Block} ??
	labels: [dynamic]Label,
	// sections: map[^Block]string, // Lookup Section a block belongs in? 
}
Reg :: struct {
	reg:  GeneralPurpose,
	bits: u8,
}

RegMem :: union {
	Reg,
	Mem,
}
MemReal :: struct {} // m32real, m64real, m80real
Mem :: struct {}
MemPtr :: struct {} // m16:16, m16:32
Imm :: u64
Rel :: struct {}
Ptr :: struct {} // jmp far [bx+si+0x7401]   jnz near 0x4856
MOff :: struct {}
Prefixes :: bit_set[GeneralPurpose]

// `zax` - mapped to either `eax` or `rax` Z prefix for native size

// ["mov, "W:r64/m64, r64", "MR", "REX.W 89 /r"   , "X64 XRelease"],
// ["mov, "W:r64/m64, id" , "MI", "REX.W C7 /0 id", "X64 XRelease"],
// ["mov, "W:r64, r64/m64", "RM", "REX.W 8B /r"   , "X64"],

@(export)
mov :: proc {
	mov_rr,
	mov_mr,
	mov_mi,
	mov_rm,
	mov_ri,
	mov_ro,
}
mov_rr :: proc(b: ^Block, rd: Reg, rs: Reg, p: Prefixes = {}) {
	// Todo: prefixes, rex
	// if is_rex(rd){
	// 	append(&b.buf,123)
	// }
	// apply_prefixes(&b.buf,p)
	append(&b.buf, mod_rm_byte(0x11, rs.reg, rd.reg))

	switch rd.bits {
	case 64:
		append(&b.buf, 0x89)
	}
}
mov_mr :: proc(b: ^Block, rm: RegMem, r: Reg, p: Prefixes = {}) {}
mov_mi :: proc(b: ^Block, rm: RegMem, i: Imm, p: Prefixes = {}) {}
mov_rm :: proc(b: ^Block, r: Reg, rm: RegMem, p: Prefixes = {}) {}
mov_ri :: proc(b: ^Block, r: Reg, i: Imm, p: Prefixes = {}) {}
mov_ro :: proc(b: ^Block, r: Reg, o: MOff, p: Prefixes = {}) {}


address_of :: proc {
	address_of_rm,
}
//[bx+si+0x188] [bx+si-0x7d] [cs:si+0x0]
address_of_rm :: proc(rm: RegMem) -> RegMem {
	return nil
}

mod_rm_byte :: proc(mod: u8, src: GeneralPurpose, dst: GeneralPurpose) -> u8 {
	// TODO: lookup indices, fix mod
	return u8(mod) << 6 | u8(dst) << 3 | u8(src)
}

GeneralPurpose :: enum {
	RAX,
	R0,
	EAX,
	R0D,
	AX,
	R0W,
	AH,
	AL,
	R0B,
	//
	RCX,
	R1,
	ECX,
	R1D,
	CX,
	R1W,
	CH,
	CL,
	R1B,
	//
	RDX,
	R2,
	EDX,
	R2D,
	DX,
	R2W,
	DH,
	DL,
	R2B,
	//
	RBX,
	R3,
	EBX,
	R3D,
	BX,
	R3W,
	BH,
	BL,
	R3B,
	//
	RSP,
	R4,
	ESP,
	R4D,
	SP,
	R4W,
	SPL,
	R4B,
	//
	RBP,
	R5,
	EBP,
	R5D,
	BP,
	R5W,
	BPL,
	R5B,
	//
	RSI,
	R6,
	ESI,
	R6D,
	SI,
	R6W,
	SIL,
	R6B,
	//
	RDI,
	R7,
	EDI,
	R7S,
	DI,
	R7W,
	DIL,
	R7B,
	// REX REGISTERS:
	R8,
	R8D,
	R8W,
	R8B,
	//
	R9,
	R9D,
	R9W,
	R9B,
	//
	R10,
	R10D,
	R10W,
	R10B,
	//
	R11,
	R11D,
	R11W,
	R11B,
	//
	R12,
	R12D,
	R12W,
	R12B,
	//
	R13,
	R13D,
	R13W,
	R13B,
	//
	R14,
	R14D,
	R14W,
	R14B,
	//
	R15,
	R15S,
	R15W,
	R15B,
}

/*
 #include <asmjit/x86.h>
 #include <stdio.h>
 using namespace asmjit;
 // Signature of the generated function.
 typedef int (*SumFunc)(const int* arr, size_t count);

 int main() {
   JitRuntime rt;                    // Create a runtime specialized for JIT.
   CodeHolder code;                  // Create a CodeHolder.

   code.init(rt.environment(),       // Initialize code to match the JIT environment.
             rt.cpuFeatures());
   x86::Assembler a(&code);          // Create and attach x86::Assembler to code.

   // Decide between 32-bit CDECL, WIN64, and SysV64 calling conventions:
   //   32-BIT - passed all arguments by stack.
   //   WIN64  - passes first 4 arguments by RCX, RDX, R8, and R9.
   //   UNIX64 - passes first 6 arguments by RDI, RSI, RCX, RDX, R8, and R9.
   x86::GeneralPurpose arr, cnt;
   x86::GeneralPurpose sum = x86::eax;           // Use EAX as 'sum' as it's a return register.

   if (ASMJIT_ARCH_BITS == 64) {
   #if defined(_WIN32)
     arr = x86::rcx;                 // First argument (array ptr).
     cnt = x86::rdx;                 // Second argument (number of elements)
   #else
     arr = x86::rdi;                 // First argument (array ptr).
     cnt = x86::rsi;                 // Second argument (number of elements)
   #endif
   }
   else {
     arr = x86::edx;                 // Use EDX to hold the array pointer.
     cnt = x86::ecx;                 // Use ECX to hold the counter.
     // Fetch first and second arguments from [ESP + 4] and [ESP + 8].
     a.mov(arr, x86::ptr(x86::esp, 4));
     a.mov(cnt, x86::ptr(x86::esp, 8));
   }

   Label Loop = a.newLabel();        // To construct the loop, we need some labels.
   Label Exit = a.newLabel();

   a.xor_(sum, sum);                 // Clear 'sum' register (shorter than 'mov').
   a.test(cnt, cnt);                 // Border case:
   a.jz(Exit);                       //   If 'cnt' is zero jump to 'Exit' now.

   a.bind(Loop);                     // Start of a loop iteration.
   a.add(sum, x86::dword_ptr(arr));  // Add int at [arr] to 'sum'.
   a.add(arr, 4);                    // Increment 'arr' pointer.
   a.dec(cnt);                       // Decrease 'cnt'.
   a.jnz(Loop);                      // If not zero jump to 'Loop'.

   a.bind(Exit);                     // Exit to handle the border case.
   a.ret();                          // Return from function ('sum' == 'eax').
   // ----> x86::Assembler is no longer needed from here and can be destroyed <----

   SumFunc fn;
   Error err = rt.add(&fn, &code);   // Add the generated code to the runtime.

   if (err) return 1;                // Handle a possible error returned by AsmJit.
   // ----> CodeHolder is no longer needed from here and can be destroyed <----

   static const int array[6] = { 4, 8, 15, 16, 23, 42 };

   int result = fn(array, 6);        // Execute the generated code.
   printf("%d\n", result);           // Print sum of array (108).

   rt.release(fn);                   // Explicitly remove the function from the runtime
   return 0;                         // Everything successful...
 }
*/
