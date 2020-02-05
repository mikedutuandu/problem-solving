#1. Stack=======================================
# An collection of items where items are added to and removed from the end called the “top.”
class Stack:
    def __init__(self):
        self.items = []

    def isEmpty(self):
        return self.items == []

    def push(self, item):
        self.items.append(item)

    def pop(self):
        return self.items.pop()

    def peek(self):
        return self.items[len(self.items) - 1]

    def size(self):
        return len(self.items)

#2. Queue===================================
#A queue is an collection of items where the addition of new items happens at one end, called the “rear,”
# and the removal of existing items occurs at the other end, commonly called the “front.”
# As an element enters the queue it starts at the rear and makes its way toward the front,
# waiting until that time when it is the next element to be removed.


class Queue:
    def __init__(self):
        self.items = []

    def isEmpty(self):
        return self.items == []

    def enqueue(self, item):
        self.items.insert(0,item)

    def dequeue(self):
        return self.items.pop()

    def size(self):
        return len(self.items)


#3. Linked list=============================================
# is a collection of items where each item holds a relative position with respect to the others. Some possible unordered list operations are given below.
class Node:
    def __init__(self, initdata):
        self.data = initdata
        self.next = None

    def getData(self):
        return self.data

    def getNext(self):
        return self.next

    def setData(self, newdata):
        self.data = newdata

    def setNext(self, newnext):
        self.next = newnext


class UnorderedList:

    def __init__(self):
        self.head = None

    def isEmpty(self):
        return self.head == None

    def size(self):
        current = self.head
        count = 0
        while current != None:
            count = count + 1
            current = current.getNext()

        return count

    def add(self, item):
        temp = Node(item)
        temp.setNext(self.head)
        self.head = temp

    def remove(self, item):
        current = self.head
        previous = None
        found = False
        while not found:
            if current.getData() == item:
                found = True
            else:
                previous = current
                current = current.getNext()

        if previous == None:
            self.head = current.getNext()
        else:
            previous.setNext(current.getNext())

    def search(self, item):
        current = self.head
        found = False
        while current != None and not found:
            if current.getData() == item:
                found = True
            else:
                current = current.getNext()

        return found



mylist = UnorderedList()

mylist.add(31)
mylist.add(77)
mylist.add(17)
mylist.add(93)
mylist.add(26)
mylist.add(54)

print(mylist.size())
print(mylist.search(93))
print(mylist.search(100))

mylist.add(100)
print(mylist.search(100))
print(mylist.size())

mylist.remove(54)
print(mylist.size())
mylist.remove(93)
print(mylist.size())
mylist.remove(31)
print(mylist.size())
print(mylist.search(93))


class OrderedList:
    def __init__(self):
        self.head = None

    def search(self, item):
        current = self.head
        found = False
        stop = False
        while current != None and not found and not stop:
            if current.getData() == item:
                found = True
            else:
                if current.getData() > item:
                    stop = True
                else:
                    current = current.getNext()

        return found

    def add(self, item):
        current = self.head
        previous = None
        stop = False
        while current != None and not stop:
            if current.getData() > item:
                stop = True
            else:
                previous = current
                current = current.getNext()

        temp = Node(item)
        if previous == None:
            temp.setNext(self.head)
            self.head = temp
        else:
            temp.setNext(current)
            previous.setNext(temp)



mylist = OrderedList()
mylist.add(31)
mylist.add(77)
mylist.add(17)
mylist.add(93)
mylist.add(26)
mylist.add(54)

print(mylist.size())
print(mylist.search(93))
print(mylist.search(100))


# 4. Binary search tree( BTS )==============================
#IMPORTANT: DIEM HOI QUY LA 1 NODE CO LEFT VA RIGHT = NONE
class TreeNode:
    def __init__(self, key):
        self.left = None
        self.right = None
        self.data = key


def insert_node(root, node):
    if root is None:
        root = node
    else:
        if root.data < node.data:
            if root.right is None:
                root.right = node
            else:
                insert_node(root.right, node)
        else:
            if root.left is None:
                root.left = node
            else:
                insert_node(root.left, node)


def in_order_traversal(root):
    if root:
        in_order_traversal(root.left)
        print(root.data)
        in_order_traversal(root.right)


def is_bst(root, l=None, r=None):
    if (root == None):
        return True

    if (l != None and root.data < l.data):
        return False

    if (r != None and root.data > r.data):
        return False

    return is_bst(root.left, l, root) and is_bst(root.right, root, r)

# A binary tree is balanced if for each node in the tree, the difference between the height of the right subtree and the left subtree is at most one.
# https://www.afternerd.com/blog/python-check-tree-balanced/

def is_balanced_helper(root):
    if root is None:
        return 0

    left_height = is_balanced_helper(root.left)
    right_height = is_balanced_helper(root.right)

    if abs(left_height - right_height) > 1:
        return -1

    return max(left_height, right_height) + 1

def is_balanced(root):
    return is_balanced_helper(root) > -1


r = TreeNode(55)
insert_node(r, TreeNode(35))
insert_node(r, TreeNode(25))
insert_node(r, TreeNode(45))
insert_node(r, TreeNode(75))
insert_node(r, TreeNode(65))
insert_node(r, TreeNode(85))

# Print inoder traversal of the BST
in_order_traversal(r)


#tinh tinh trung cong data cac node tree
TOTAL = 0
NUM_NODE = 0
def avg_help(root):
    if root is not None:
        avg_help(root.left)
        global TOTAL
        global NUM_NODE
        TOTAL += root.data
        NUM_NODE += 1
        avg_help(root.right)

def avg(root):
    avg_help(root)
    if TOTAL == 0 or NUM_NODE == 0
        return 0
    return TOTAL/NUM_NODE


def avg_help_1(root,total=0,num_node=0):
    if root is not None:
        total,num_node = avg_help_1(root.left,total,num_node)

        total += root.data
        num_node += 1
        total,num_node = avg_help_1(root.right,total,num_node)
    return total,num_node

def avg_1(root):
    
   total,num_node = avg_help_1(root)
   if total ==0 or num_node == 0:
        return 0
   return total/num_node

print(avg(r))
print(avg_1(r))

#tim 1 gia tri trong cay xem co hay ko
FOUND = False
def search_tree(r,data):
    if r is not None:
        search_tree(r.left,data)
        if r.data == data:
            global FOUND
            FOUND = True
        search_tree(r.right,data)

def search_tree_1(r,data,found=0):
    if r is not None:
        found = search_tree_1(r.left,data,found)
        if r.data == data:
            found += 1
        found = search_tree_1(r.right,data,found)
    return found

#tim node co data lon nhat
MAX = 0
def max_node_tree(r):
    global MAX
    if r is not None:
        max_node_tree(r.left)
        if r.data > MAX:
            MAX = r.data
        max_node_tree(r.right)

def max_node_tree_1(r,max_data=0):
    if r is not None:
        max_data = max_node_tree_1(r.left,max_data)
        if r.data > max_data:
            max_data = r.data
        max_data = max_node_tree_1(r.right,max_data)
    return max_data


print(max_node_tree(r))
print(MAX)

