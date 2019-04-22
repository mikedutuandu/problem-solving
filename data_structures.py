#1. Stack=======================================
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

    def add(self, item):
        temp = Node(item)
        temp.setNext(self.head)
        self.head = temp

    def size(self):
        current = self.head
        count = 0
        while current != None:
            count = count + 1
            current = current.getNext()

        return count

    def search(self, item):
        current = self.head
        found = False
        while current != None and not found:
            if current.getData() == item:
                found = True
            else:
                current = current.getNext()

        return found

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

    def isEmpty(self):
        return self.head == None

    def size(self):
        current = self.head
        count = 0
        while current != None:
            count = count + 1
            current = current.getNext()

        return count


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


# utility class to pass height object
class Height:
    def __init__(self):
        self.height = 0


def is_balanced(root, height):
    lh = Height()
    rh = Height()

    if root is None:
        return True

    l = is_balanced(root.left, lh)
    r = is_balanced(root.right, rh)

    height.height = max(lh.height, rh.height) + 1

    if abs(lh.height - rh.height) <= 1:
        return l and r

    return False




r = TreeNode(55)
insert_node(r, TreeNode(35))
insert_node(r, TreeNode(25))
insert_node(r, TreeNode(45))
insert_node(r, TreeNode(75))
insert_node(r, TreeNode(65))
insert_node(r, TreeNode(85))

# Print inoder traversal of the BST
in_order_traversal(r)

h = Height()
if is_balanced(r,h):
    print("Tree is balanced")
else:
    print("Tree is not balanced")
