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

# 1. while cho den khi lay du so number
# 2. tao 1 random tu 1-100
# 3. ung voi moi random, duyen list de lay dung book base tren compare random number va percent of book
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

    def get_basic_random(self, number=5):
        recommend = []

        while len(recommend) <= number:
            rand_pos = random.randint(0, len(self.items) - 1)
            recommend.append(self.items[rand_pos])

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
# 1. duyet str roi bo vo 1 dict voi key la ki tu, value la so lan xuat hien cua ki tu do
# 2. duyet dict va tim thang key nao co value lon nhat

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
#. 1. chon 1 so g nho doan no la can bac 2 cua num, chon 1 sai so chap nhan dc a
# 2. lap cho den khi nao chon dc g -> num/2(trung binh cong: vd g = ((4+ 16/4))/2 ) thoa : g = (g+num/g)/2


def find_square(num):
  g = 0.00001
  a = 0.00001

  while abs((g*g) - num) > a:
    g = (g + (num/g))/2
  return g

print(find_square(9))


# How to sort a single string without using any library functions with O(N) time complexity
# 1. init 1 list 26 ki ty tu dem ki tu xuat hien tu a->z
#. 2 dem kitu xuat hien trong mang (dua vao chuyen kitu sang so interger)
# 3. duyen cais list tren a in ra theo thu tu a->z
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

# Give an array, a target =9, find an algorithm print 2 element in this array has the total equal target with time complex is n
def find_pair_sum_with_target(list1,targer):
  for i in list1:
    if (targer-i) in list1:
      print(i,targer-i)
      list1.remove(i)
      list1.remove(targer-i)



list1 = [1,5,3,7,5,6,7,8]

find_pair_sum_with_target(list1,10)

#Implement Linked list ,
# 1 .delete node with O(1) :https://leetcode.com/problems/delete-node-in-a-linked-list/solution/
# 2. Reverse a linked list https://www.geeksforgeeks.org/reverse-a-linked-list/
class Node:
    def __init__(self, init_data):
        self.data = init_data
        self.next_node = None

    def get_data(self):
        return self.data

    def get_next_node(self):
        return self.next_node

    def set_data(self, data):
        self.data = data

    def set_next_node(self, node):
        self.next_node = node


class LinkedList:
    def __init__(self):
        self.head = None

    def add(self, node):
        node.next_node = self.head
        self.head = node

    def remove(self, node):
        node.data = node.next_node.data
        node.next_node = node.next_node.next_node

    def reverse(self):
        current = self.head
        prev = Node
        next = Node

        while current != None:
            next = current.get_next_node()
            current.set_next_node(prev)
            prev = current
            current = next

        self.head = prev



lk1 = LinkedList()

node1 = Node(1)
lk1.add(node1)

node2 = Node(2)
lk1.add(node2)

node3 = Node(2)
lk1.add(node3)

lk1.remove(node2)

# Implement a queue using linkedlist
# 1. implement front tro den vi tri dau, rear tro den vi tri cuoi cua queue
# 2. enqueue: add vao vi tri cuoi (rear)
# 3. dequeue: remove o vi tri dau tien (front)

class Node:

    def __init__(self, data):
        self.data = data
        self.next = None


class Queue:

    def __init__(self):
        self.front = self.rear = None

    def isEmpty(self):
        return self.front == None

    # Method to add an item to the queue
    def EnQueue(self, item):
        temp = Node(item)

        if self.rear == None:
            self.front = self.rear = temp
            return
        self.rear.next = temp
        self.rear = temp

        # Method to remove an item from queue

    def DeQueue(self):

        if self.isEmpty():
            return
        temp = self.front
        self.front = temp.next

        if (self.front == None):
            self.rear = None
        return str(temp.data)

q = Queue()
q.EnQueue(10)
q.EnQueue(20)
q.DeQueue()
q.DeQueue()
q.EnQueue(30)
q.EnQueue(40)
q.EnQueue(50)




