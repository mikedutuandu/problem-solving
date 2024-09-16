package main

import "fmt"

/*
Bubble Sort in Go, which is one of the easiest sorting algorithms to understand:

Bubble Sort goes through the list and compares each pair of items.
If two items are in the wrong order, it swaps them.
It keeps doing this until the list is completely sorted.
With each pass through the list, the biggest items "bubble up" to the end.
*/

// BubbleSort function
func BubbleSort(arr []int) {
	n := len(arr)
	for i := 0; i < n-1; i++ {
		for j := 0; j < n-i-1; j++ {
			// Swap if the current element is greater than the next element
			if arr[j] > arr[j+1] {
				arr[j], arr[j+1] = arr[j+1], arr[j]
			}
		}
	}
}

func main() {
	// Sample array to sort
	arr := []int{64, 25, 12, 22, 11}

	// Call BubbleSort function
	BubbleSort(arr)

	// Print the sorted array
	fmt.Println("Sorted array:", arr)
}
