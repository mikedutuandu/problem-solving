# 1. Linear search( sequential search),  time complexity of above algorithm is O(n)
# 2. Binary search : k = log n  ( n = 2^k ) (we had to divide the array k times )
#  Search a sorted array by repeatedly dividing the search interval in half.
#  Begin with an interval covering the whole array. If the value of the search key is less than the item in the middle of the interval,
#  narrow the interval to the lower half. Otherwise narrow it to the upper half. Repeatedly check until the value is found or the interval is empty.

#  Time complexity: https://hackernoon.com/what-does-the-time-complexity-o-log-n-actually-mean-45f94bb5bfbf


#Recursive implementation of Binary Search
def binary_search(alist, item):
    if len(alist) == 0:
        return False
    else:
        midpoint = len(alist) // 2
        if alist[midpoint] == item:
            return True
        else:
            if item < alist[midpoint]:
                return binary_search(alist[:midpoint], item)
            else:
                return binary_search(alist[midpoint + 1:], item)


testlist = [0, 1, 2, 8, 13, 17, 19, 32, 42, ]
print(binary_search(testlist, 3))
print(binary_search(testlist, 13))

#Iterative implementation of Binary Search
def binarySearch(arr, l, r, x):
    while l <= r:

        mid = l + r // 2

        if arr[mid] == x:
            return mid

        elif arr[mid] < x:
            l = mid + 1

        else:
            r = mid - 1
    return -1


# Test array
arr = [2, 3, 4, 10, 40]
x = 10

# Function call
result = binarySearch(arr, 0, len(arr) - 1, x)