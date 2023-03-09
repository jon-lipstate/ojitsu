import re
import json
import os


def entry_to_dict(entry):
    entry_dict = {}
    for line in entry.split('\n'):
        if ':' in line:
            key, val = line.split(':', 1)
            entry_dict[key.strip()] = val.strip()
    return entry_dict


path = os.path.dirname(os.path.realpath(__file__)) + "/XED/xed-isa.txt"
# with open(path, 'r') as file:
#     instrs = group_instructions_by_extension(file)
#     print(instrs)


def parse_instructions(filename):

    # regex pattern for matching the extension field in each entry
    ext_pattern = re.compile(r'EXTENSION\s*:\s*(\w+)')

    # dictionary to store instructions grouped by extension
    instructions_by_ext = {}

    # read in the file
    with open(filename, 'r') as f:
        current_entry = ''
        current_ext = ''

        # iterate over each line in the file
        for line in f:
            # skip any empty lines or comments
            if not line.strip() or line.strip().startswith('#'):
                continue

            # add the current line to the current entry being parsed
            current_entry += line

            # check if the current line specifies an extension
            ext_match = ext_pattern.match(line)
            if ext_match:
                # if so, update the current extension
                current_ext = ext_match.group(1)

                # if this is the first entry for this extension, create a new list
                if current_ext not in instructions_by_ext:
                    instructions_by_ext[current_ext] = []

            # check if the current line ends an entry
            if line.strip() == '}':
                # if so, add the current entry to the list for the current extension
                instructions_by_ext[current_ext].append(
                    entry_to_dict(current_entry.strip()))

                # reset the current entry
                current_entry = ''
                current_ext = ''

    return instructions_by_ext


def collect_unique_entries(data, field):
    entries = set()
    for entry in data:
        if field in entry:
            fields = entry[field].split()
            entries.update(fields)
    return " ".join(entries)


def save_files(data_dict, output_dir):
    # Create output directory if it doesn't exist
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Loop through dictionary and save files
    for key, value in data_dict.items():
        filename = os.path.join(output_dir, f"{key}.json")
        with open(filename, 'w') as f:
            f.write(f"[\n")
            for entry in value:
                f.write(f"{entry},\n")
            f.write(f"]\n")


pi = parse_instructions(path)
# sort on mnemonics:
for k, arr in pi.items():
    pi[k] = sorted(arr, key=lambda x: x["ICLASS"])

save_files(pi, "./db_codegen/xed/split")


# attrs = collect_unique_entries(pi["BASE"], "OPERANDS")
# print(attrs)

# extract specific portion for parse-testing
# key = "IFORM"
# f = []
# for entry in pi["BASE"]:
#     if key in entry:
#         f.append(entry[key])
#     pi[k] = f
# with open("./db_codegen/"+key+".JSON", 'w') as tmp:
#     json.dump(f, tmp)
