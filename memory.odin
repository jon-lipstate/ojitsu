package ojitsu
//
import win32 "core:sys/windows"
import "core:fmt"
PAGE_SIZE :: 4096
//
get_os_memory :: proc() -> [^]u8 {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	platform_buf: [^]u8
	when ODIN_OS == .Windows {
		platform_buf = transmute([^]u8)win32.VirtualAlloc(nil, uint(PAGE_SIZE), win32.MEM_RESERVE | win32.MEM_COMMIT, win32.PAGE_READWRITE)
	} else when ODIN_OS == .Linux {
		// int prot = PROT_READ | PROT_WRITE;
		// int flags = MAP_ANONYMOUS | MAP_PRIVATE;
		// return mmap(NULL, PAGE_SIZE, prot, flags, -1, 0);
	}
	// fmt.printf("Allocated: %X\n", platform_buf)
	return platform_buf
}
protect_os_memory :: proc(os_mem: [^]u8) {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	when ODIN_OS == .Windows {
		old: win32.DWORD
		// fmt.printf("Protecting: %X\n", os_mem)
		win32.VirtualProtect(os_mem, PAGE_SIZE, win32.PAGE_EXECUTE_READ, &old)
	} else when ODIN_OS == .Linux {
		// mprotect(buf, sizeof(*buf), PROT_READ | PROT_EXEC);
	}
}
free_os_memory :: proc(os_mem: [^]u8) {
	spall.SCOPED_EVENT(&spall_ctx, &spall_buffer, #procedure)
	when ODIN_OS == .Windows {
		win32.VirtualFree(os_mem, 0, win32.MEM_RELEASE)
	} else when ODIN_OS == .Linux {
		// munmap(buf, PAGE_SIZE)
	}
}
