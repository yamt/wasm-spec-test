import re
import sys

infilename = sys.argv[1]
base, _ = infilename.split(".bin.wast")
n = 0


def text_to_bin(text):
    hex_text = re.sub('[\\\\"]', '', text)
    b = bytes.fromhex(hex_text)
    return b

in_bin = False
outfp = None
with open(infilename) as infp:
    for l in infp.readlines():
        sl = l.strip()
        #print(f"line: '{sl}' in_bin {in_bin}")
        if in_bin:
            if sl == ')':
                 in_bin = False
                 outfp.close()
                 n += 1
        if in_bin:
            print(f";; binary {sl}")
            outfp.write(text_to_bin(sl))
        else:
            print(l, end='')
            if sl == '(module binary':
                 wasm = f"{base}.{n}.wasm"
                 print('"\\00\\61\\73\\6d\\01\\00\\00\\00"')
                 print(f";; wasm {wasm}")
                 outfp = open(wasm, 'wb')
                 in_bin = True
