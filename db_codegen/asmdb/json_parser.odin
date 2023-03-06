package asmdb_parser
// import "core:encoding/json"
// import "core:fmt"

// // x86_json :: #load("./json/x86data.json")
// // mneumonics :: #load("./json/MNEUMONICS.json")
// // data, ok := os.read_entire_file_from_filename("x86data.json")
// // if !ok do return
// // defer delete(data)
// mmmain :: proc() {
// 	// json_data, err := json.parse(VEX)
// 	// if err != .None {
// 	// 	fmt.eprintln("Failed to parse the json file.")
// 	// 	fmt.eprintln("Error:", err)
// 	// 	return
// 	// }
// 	// fmt.println(len(json_data.(json.Array)))

// 	// x86_object := json_data.(json.Object)
// 	// // HAND ENCODED
// 	// // extensions := read_extensions(x86_object["extensions"].(json.Array)) // ["AVX2",...]
// 	// // registers := read_registers(x86_object["registers"].(json.Object))
// 	// // architectures := read_to_string(x86_object["architectures"].(json.Array)) // ["ANY","X86","X64"] NOTE: Replace ANY with bitset[Arch] {X86 X64}

// 	// // Parsed for Code-Gen
// 	// specialRegs := read_specialregs(x86_object["specialRegs"].(json.Array))
// 	// // TODO: Make a map of shortcuts: aliases:= map[string]string  //eg  "_ILock" -> "Lock|ImplicitLock"
// 	// shortcuts := read_shortcuts(x86_object["shortcuts"].(json.Array))
// 	// // TODO: Attributes are descriptors of the expanded shortcuts
// 	// attributes := read_attributes(x86_object["attributes"].(json.Array))

// 	// instructions := read_intstructions(x86_object["instructions"].(json.Array))

// 	// // fmt.println(registers["r8"])
// 	// defer json.destroy_value(json_data)
// }
// read_to_string :: proc(str_arr: json.Array, allocator := context.allocator) -> []string {
// 	context.allocator = allocator
// 	entries := make([]string, len(str_arr))
// 	i := 0
// 	for str_val in str_arr {
// 		entries[i] = str_val.(json.String)
// 		i += 1
// 	}
// 	return entries
// }
// read_extensions :: proc(ext_arr: json.Array, allocator := context.allocator) -> []string {
// 	context.allocator = allocator
// 	entries := make([]string, len(ext_arr))
// 	i := 0
// 	for ext_val in ext_arr {
// 		ext_obj := ext_val.(json.Object)
// 		entries[i] = ext_obj["name"].(json.String)
// 		i += 1
// 	}
// 	return entries
// }
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// // Attributes
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// Attribute :: struct {
// 	name: string,
// 	type: string,
// 	doc:  string,
// }
// read_attributes :: proc(attrs: json.Array, allocator := context.allocator) -> []Attribute {
// 	context.allocator = allocator
// 	attributes := make([]Attribute, len(attrs))
// 	i := 0
// 	for attr in attrs {
// 		a := attr.(json.Object)
// 		name := a["name"].(json.String)
// 		doc := a["doc"].(json.String)
// 		type := a["type"].(json.String)
// 		attributes[i] = Attribute{name, type, doc}
// 		i += 1
// 	}
// 	return attributes
// }
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// // SpecialRegs
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// SpecialReg :: struct {
// 	name:  string,
// 	group: string,
// 	doc:   string,
// }
// read_specialregs :: proc(arr: json.Array, allocator := context.allocator) -> []SpecialReg {
// 	context.allocator = allocator
// 	result := make([]SpecialReg, len(arr))
// 	i := 0
// 	for val in arr {
// 		s := val.(json.Object)
// 		name := s["name"].(json.String)
// 		doc := s["doc"].(json.String)
// 		group := s["group"].(json.String)
// 		result[i] = SpecialReg{name, group, doc}
// 		i += 1
// 	}
// 	return result
// }
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// // Shortcuts
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// Shortcut :: struct {
// 	name:   string,
// 	expand: string,
// }
// read_shortcuts :: proc(arr: json.Array, allocator := context.allocator) -> []Shortcut {
// 	context.allocator = allocator
// 	result := make([]Shortcut, len(arr))
// 	i := 0
// 	for val in arr {
// 		s := val.(json.Object)
// 		name := s["name"].(json.String)
// 		expand := s["expand"].(json.String)
// 		result[i] = Shortcut{name, expand}
// 		i += 1
// 	}
// 	return result
// }
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// // Registers
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// Register :: struct {
// 	kind:  string,
// 	any:   Maybe(string),
// 	names: []string,
// }

// read_registers :: proc(obj: json.Object, allocator := context.allocator) -> map[string]Register {
// 	context.allocator = allocator
// 	result := make(map[string]Register)
// 	i := 0
// 	for k, v_val in obj {
// 		v := v_val.(json.Object)
// 		r := Register{}
// 		r.kind = v["kind"].(json.String)
// 		a := v["any"]
// 		if a != nil {
// 			r.any = a.(json.String)
// 		} else {
// 			r.any = nil
// 		}
// 		n_arr := v["names"].(json.Array)
// 		r.names = make([]string, len(n_arr))
// 		for s := 0; s < len(r.names); s += 1 {
// 			r.names[s] = n_arr[s].(json.String)
// 		}
// 		result[k] = r
// 		i += 1
// 	}
// 	return result
// }
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// // Raw Instructions
// //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
// Raw_Instruction :: struct {
// 	name:      string,
// 	operands:  string,
// 	encoding:  string,
// 	opcode:    string,
// 	meta_data: Maybe(string),
// }
// read_intstructions :: proc(arr: json.Array, allocator := context.allocator) -> []Raw_Instruction {
// 	context.allocator = allocator
// 	result := make([]Raw_Instruction, len(arr))
// 	e := 0
// 	for iarr_val in arr {
// 		inst := Raw_Instruction{}
// 		iarr := iarr_val.(json.Array)
// 		inst.name = iarr[0].(json.String)
// 		inst.operands = iarr[1].(json.String)
// 		inst.encoding = iarr[2].(json.String)
// 		inst.opcode = iarr[3].(json.String)
// 		inst.meta_data = nil
// 		if len(iarr) >= 5 {
// 			inst.meta_data = iarr[4].(json.String)
// 		}
// 		result[e] = inst
// 		e += 1
// 	}
// 	return result
// }
