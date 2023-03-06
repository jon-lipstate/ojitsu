import requests
from bs4 import BeautifulSoup
import json
import time


def extract_page(index, link, op, summary):
    url = 'https://www.felixcloutier.com/x86/' + link
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    tables = soup.findAll('table')
    # title = soup.findAll('h1')[0].get_text()  # TODO: split on the utf8 dash

    def filter_st(tag):
        return tag and 'ST(' in tag.text
    fpu_mode = False
    if len(soup.find_all(filter_st)) > 0:
        fpu_mode = True
    # Guard for unexpected Tables:
    if len(tables) < 2:
        print("not 2 tables", len(tables), link, op, summary)
        breakpoint()

    # Read Tables into dictionaries:
    instr_table = tables[0]

    fpu_header1 = ["Opcode/Instruction",
                   "64-Bit Mode", "Compat/Leg Mode", "Description"]
    fpu_header2 = ["Opcode", "Instruction",
                   "64-Bit Mode", "Compat/Leg Mode", "Description"]

    op_en_keys = ["op_en", "operand_1", "operand_2", "operand_3", "operand_4"]
    op_en_keys_avx = ["op_en", "tuple_type", "operand_1",
                      "operand_2", "operand_3", "operand_4"]

    instr_keys_avx = ["opcode", "op_en", "x64_x86", "feature_flag", "desc"]
    instr_keys = ["opcode", "instr", "op_en", "x64", "x86", "desc"]
    instr_keys_fpu = ["opcode", "x64", "x86", "desc"]
    instr_keys_fpu2 = ["opcode", "instr", "x64", "x86", "desc"]
    keys = instr_keys
    instr_table_ths = [th.text for th in instr_table.find_all('th')]
    if len(instr_table_ths) == 4:
        keys = instr_keys_fpu
        assert (instr_table_ths == fpu_header1)
    elif len(instr_table_ths) == 5:
        if fpu_mode:
            keys = instr_keys_fpu2
        else:
            keys = instr_keys_avx
        # assert(instr_table_ths==avx_header)
    elif len(instr_table_ths) == 6:
        keys = instr_keys
    else:
        print("<!> COL-MISMATCH ", op, instr_table_ths)
        exit(42)
    instr_rows = []
    for row in instr_table.find_all('tr')[1:]:
        values = [cell.text.strip() for cell in row.find_all('td')]
        instr_rows.append(dict(zip(keys, values)))

    # op-encoding table:
    op_en_rows = []
    if not fpu_mode:
        op_en_table = tables[1]
        for row in op_en_table.find_all('tr')[1:]:
            values = [cell.text.strip() for cell in row.find_all('td')]
            op_en_rows.append(dict(zip(op_en_keys, values)))

    # Read Description Section:
    page_desc = []
    h2 = soup.find('h2', {'id': 'description'})
    if h2 is not None:
        for elem in h2.find_next_siblings():
            if elem.name == 'h2':
                break
            if elem.name == 'p':
                page_desc.append(elem.get_text(strip=True))

    contents = {'mnemonic': op, 'summary': summary, 'index': index, 'instructions': instr_rows,
                'op_en': op_en_rows, 'page_desc': page_desc}
    if op == "MOV":
        op = link
    with open('./json/'+op+'.json', 'w') as outfile:
        json.dump(contents, outfile)


def read_index():
    url = 'https://www.felixcloutier.com/x86/index.html'
    response = requests.get(url)
    soup = BeautifulSoup(response.text, "html.parser")
    table = soup.find('table')
    rows = table.find_all('tr')[1:]  # Skip header row
    skip = ["MONITOR", "MOVDQ2Q", "XACQUIRE", "XRELEASE"]
    results = []
    for row in rows:
        link = row.find('a')['href'].replace('./', '').replace('.html', '')
        code = row.find('a').text
        desc = row.find_all('td')[1].text
        results.append((link, code, desc))
    i = 0
    for row in results[i:]:
        if row[1] in skip:
            print(row[0], i, "<!> Known Bad Page, ---> Skipping")
            i += 1
            continue
        print(row[0], i)
        extract_page(i, row[0], row[1], row[2])
        time.sleep(1)
        i += 1


# Output:
# [('AAA', 'ASCII Adjust After Addition'), ('BBB', 'Binary Coded Decimal Subtract'), ('CCC', 'Complement Carry Flag')]
read_index()
