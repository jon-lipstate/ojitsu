import requests
from bs4 import BeautifulSoup
import json
import time

# TODO: should add x87_instr:true for FPU?? how about vector-kinds
# special handling: jcc, fcmovcc, mov (file-names)

# test cases: extractps - vector with ib before mnemonic??
# enter: scrape should kill items 1&2


def extract_tables(html):
    soup = BeautifulSoup(html, 'html.parser')
    tables = []
    for tag in soup.find_all('table'):
        headers = [header.text.strip() for header in tag.find_all('th')]
        # some tables dont use th:
        if len(headers) == 0:
            headers = [header.text.strip().replace('*', '')
                       for header in tag.find('tr').find_all('td')]
        table = []
        for row in tag.find_all('tr')[1:]:
            values = [cell.text.strip().replace('*', '')
                      for cell in row.find_all('td')]
            table.append(dict(zip(headers, values)))
        # nix empty keys, TODO: allow empty values?
        table = {k: v for k, v in table.items() if k != ""}
        tables.append(table)
        next_h2 = tag.find_all_next('h2')
        if len(next_h2) > 0 and next_h2[0].get('id') == 'description':
            break
    return tables


def extract_page(index, link, op, summary):
    url = 'https://www.felixcloutier.com/x86/' + link
    response = requests.get(url)
    tables = extract_tables(response.text)

    contents = {'mnemonic': op, 'summary': summary,
                'index': index, 'tables': tables}
    if op == "MOV":
        op = link
    with open('./db_codegen/json/'+op+'.json', 'w') as outfile:
        # with open(op+'.json', 'w') as outfile:
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
    i = 187
    for row in results[i:193]:
        if row[1] in skip:
            print(row[0], i, "<!> Known Bad Page, ---> Skipping")
            i += 1
            continue
        print(row[0], i)
        extract_page(i, row[0], row[1], row[2])
        time.sleep(0.3)
        i += 1


read_index()
