#get random base on weight


import random


class book:
    def __init__(self, name, weight):
        self.name = name
        self.weight = weight
        self.percent = None


class library:

    def __init__(self):
        self.items = []

    def add(self, book):
        self.items.append(book)

    def set_percent(self):
        total_weight = 0
        for book in self.items:
            total_weight += book.weight

        for book in self.items:
            book.percent = (book.weight * 100) / total_weight

    def get_recommend(self, number):
        self.set_percent()
        recommend = []

        list_book = list(self.items)
        while len(recommend) < number:

            rand = random.randint(0, 100)
            random_item = None
            compare = self.items[0].percent
            for index, book in enumerate(list_book):
                if rand < compare:
                    random_item = book
                    del list_book[index]
                    break

                compare += book.percent

            if random_item != None:
                recommend.append(random_item)

        return recommend


def browse(list_data):
    for item in list_data:
        print(item.name)


lib = library()

b1 = book('b1', 2)

b2 = book('b2', 4)
b3 = book('b3', 3)
b4 = book('b4', 4)
b5 = book('b5', 8)

lib.add(b1)
lib.add(b2)
lib.add(b3)
lib.add(b4)
lib.add(b5)

rec = lib.get_recommend(3)

browse(rec)

# Find kth most occurred character

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

# Find square root of number without built in function

def find_square(num):
  g = 0.00001
  a = 0.00001

  while abs((g*g) - num) > a:
    g = (g + (num/g))/2
  return g

print(find_square(9))


# How to sort a single string without using any library functions with O(N) time complexity
MAX_CHAR = 26


def sort_str(str1):
    char_count = []
    for i in range(0, MAX_CHAR, 1):
        char_count.insert(i, 0)

    for i in str1:
        char_count[ord(i) - ord("a")] += 1

    sorted_str = []
    for i in range(0, MAX_CHAR, 1):
        for j in range(0, char_count[i], 1):
            sorted_str.append(chr(ord("a") + i))

    return "".join(sorted_str)


print(sort_str("jgsfsfhbwea"))
