
def find_max_char(str_char):
  l = {}
  for i in str_char:
    if i in l:
      l[i] = l[i]+1
    else:
      l[i] = 1

  found_char = None
  found_char_number = 0
  for k,v in l.items():
    if found_char_number < v:
      found_char_number = v
      found_char = k

  return found_char

newstr = "asadddddasaadsd"
print(find_max_char(newstr))

for i in "dsadsa":
    print(i)