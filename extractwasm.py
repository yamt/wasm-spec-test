import re
import sys

infilename = sys.argv[1]
base, _ = infilename.split(".bin.wast")
n = 0

placeholder_module = '"\\00\\61\\73\\6d\\01\\00\\00\\00"'


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
        if in_bin:
            print(f";; binary {sl}")
            outfp.write(text_to_bin(sl))
        else:
            # only simple cases are implemented
            m = re.match(r'\(module( \$[^ ]*){0,1} binary(.*)', sl)
            if m is not None:
                 label = m.groups()[0]
                 if label is None:
                     label = ""
                 payload = m.groups()[1]
                 wasm = f"{base}.{n}.wasm"
                 n += 1
                 outfp = open(wasm, 'wb')
                 cont = True
                 if payload and payload[-1] == ')':
                     cont = False
                     payload = payload[0:-1]
                 xs = payload.split(' ')
                 xs = xs[1:]
                 for x in xs:
                     outfp.write(text_to_bin(x))
                 print(f"(module{label} binary {placeholder_module}")
                 if cont:
                     print(f";; wasm {wasm}")
                     in_bin = True
                 else:
                     outfp.close()
                     print(")")
            else:
                 print(l, end='')
