package profiling
// src: https://gist.github.com/colrdavidson/2aadf29feeb0e9b5e1a0314617da73b9
import "core:os"
import "core:time"
import "core:intrinsics"
import "core:mem"

MANUAL_MAGIC :: u64(0x0BADF00D)

Manual_Header :: struct #packed {
	magic:           u64,
	version:         u64,
	timestamp_scale: f64,
	reserved:        u64,
}

Manual_Event_Type :: enum u8 {
	Invalid  = 0,
	Begin    = 3,
	End      = 4,
	Instant  = 5,
	Pad_Skip = 7,
}

Begin_Event :: struct #packed {
	type:     Manual_Event_Type,
	category: u8,
	pid:      u32,
	tid:      u32,
	ts:       f64,
	name_len: u8,
	args_len: u8,
}
Begin_Event_Max :: (size_of(Begin_Event) + 255 + 255)

End_Event :: struct #packed {
	type: Manual_Event_Type,
	pid:  u32,
	tid:  u32,
	ts:   f64,
}

Pad_Skip :: struct #packed {
	type: Manual_Event_Type,
	size: u32,
}

SpallContext :: struct {
	precise_time:    bool,
	timestamp_scale: f64,
	fd:              os.Handle,
}

SpallBuffer :: struct {
	data: []u8,
	head: int,
	tid:  u32,
	pid:  u32,
}

_trace_now :: proc(ctx: ^SpallContext) -> f64 {
	if !ctx.precise_time {
		return f64(time.tick_now()._nsec) / 1_000
	}

	return f64(intrinsics.read_cycle_counter())
}

_build_header :: proc(buffer: []u8, timestamp_scale: f64) -> (int, bool) #optional_ok {
	header_size := size_of(Manual_Header)
	if header_size > len(buffer) {
		return 0, false
	}

	hdr := (^Manual_Header)(raw_data(buffer))
	hdr.magic = MANUAL_MAGIC
	hdr.version = 1
	hdr.timestamp_scale = timestamp_scale
	hdr.reserved = 0

	return header_size, true
}

_build_begin :: proc(
	buffer: []u8,
	name: string,
	args: string,
	ts: f64,
	tid: u32,
	pid: u32,
) -> (
	int,
	bool,
) #optional_ok {
	ev := (^Begin_Event)(raw_data(buffer))
	name_len := min(len(name), 255)
	args_len := min(len(args), 255)

	ev_size := size_of(Begin_Event) + name_len + args_len
	if ev_size > len(buffer) {
		return 0, false
	}

	ev.type = .Begin
	ev.pid = pid
	ev.tid = tid
	ev.ts = ts
	ev.name_len = u8(name_len)
	ev.args_len = u8(args_len)
	mem.copy(raw_data(buffer[size_of(Begin_Event):]), raw_data(name), name_len)
	mem.copy(raw_data(buffer[size_of(Begin_Event) + name_len:]), raw_data(args), args_len)

	return ev_size, true
}

_build_end :: proc(buffer: []u8, ts: f64, tid: u32, pid: u32) -> (int, bool) #optional_ok {
	ev := (^End_Event)(raw_data(buffer))
	ev_size := size_of(End_Event)
	if ev_size > len(buffer) {
		return 0, false
	}

	ev.type = .End
	ev.pid = pid
	ev.tid = tid
	ev.ts = ts
	return ev_size, true
}

_buffer_begin :: proc(ctx: ^SpallContext, buffer: ^SpallBuffer, name: string, args: string = "") {
	if buffer.head + Begin_Event_Max > len(buffer.data) {
		buffer_flush(ctx, buffer)
	}

	buffer.head += _build_begin(
		buffer.data[buffer.head:],
		name,
		args,
		_trace_now(ctx),
		buffer.tid,
		buffer.pid,
	)
}

_buffer_end :: proc(ctx: ^SpallContext, buffer: ^SpallBuffer) {
	ts := _trace_now(ctx)

	if buffer.head + size_of(End_Event) > len(buffer.data) {
		buffer_flush(ctx, buffer)
	}

	buffer.head += _build_end(buffer.data[buffer.head:], ts, buffer.tid, buffer.pid)
}

init :: proc(filename: string) -> (SpallContext, bool) #optional_ok {
	ctx := SpallContext{}

	fd, err := os.open(filename, os.O_WRONLY | os.O_APPEND | os.O_CREATE | os.O_TRUNC, 0o600)
	if err != os.ERROR_NONE {
		return ctx, false
	}
	ctx.fd = fd

	freq, ok := time.tsc_frequency()
	ctx.precise_time = ok
	if !ok {
		ctx.timestamp_scale = 1
	} else {
		ctx.timestamp_scale = (1 / f64(freq)) * 1_000_000
	}

	temp := [size_of(Manual_Header)]u8{}
	_build_header(temp[:], ctx.timestamp_scale)
	os.write(ctx.fd, temp[:])

	return ctx, true
}

buffer_init :: proc(
	size: int = 0x10_0000,
	tid: u32 = 0,
	pid: u32 = 0,
	allocator := context.allocator,
) -> (
	SpallBuffer,
	bool,
) #optional_ok {
	buffer := SpallBuffer{}
	ret, err := make([]u8, size, allocator)
	if err != nil {
		return buffer, false
	}
	buffer.data = ret
	buffer.tid = tid
	buffer.pid = pid
	buffer.head = 0

	return buffer, true
}

buffer_flush :: proc(ctx: ^SpallContext, buffer: ^SpallBuffer) {
	os.write(ctx.fd, buffer.data[:buffer.head])
	buffer.head = 0
}

buffer_quit :: proc(ctx: ^SpallContext, buffer: ^SpallBuffer) {
	buffer_flush(ctx, buffer)

	delete(buffer.data)
	buffer^ = SpallBuffer{}
}

quit :: proc(ctx: ^SpallContext) {
	if ctx == nil {
		return
	}

	os.close(ctx.fd)
	ctx^ = SpallContext{}
}

@(deferred_out = _buffer_end)
event_scope :: proc(
	ctx: ^SpallContext,
	buffer: ^SpallBuffer,
	name: string,
	args: string = "",
) -> (
	^SpallContext,
	^SpallBuffer,
) {
	_buffer_begin(ctx, buffer, name, args)
	return ctx, buffer
}
