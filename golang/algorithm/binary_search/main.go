package main

import "fmt"

// binarySearch function
func binarySearch(arr []int, target int) int {
	low := 0
	high := len(arr) - 1

	for low <= high {
		mid := low + (high-low)/2

		// Check if the target is at the mid position
		if arr[mid] == target {
			return mid // Target found
		}

		// If target is greater, ignore the left half
		if target > arr[mid] {
			low = mid + 1
		} else { // If target is smaller, ignore the right half
			high = mid - 1
		}
	}

	return -1 // Target not found
}

func main() {
	// A sorted array for binary search
	arr := []int{1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21}
	target := 9

	// Call binarySearch and get the result
	result := binarySearch(arr, target)

	if result != -1 {
		fmt.Printf("Element %d found at index %d\n", target, result)
	} else {
		fmt.Printf("Element %d not found in the array\n", target)
	}

}