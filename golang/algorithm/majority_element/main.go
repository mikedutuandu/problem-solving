package main

import "fmt"

/*
Given an array nums of size n, return the majority element.

The majority element is the element that appears more than ⌊n / 2⌋ times. You may assume that the majority element always exists in the array.



Example 1:

Input: nums = [3,2,3]
Output: 3
Example 2:

Input: nums = [2,2,1,1,1,2,2]
Output: 2

*/

/*
Solution: Boyer-Moore Voting Algorithm
*/
func majorityElement(nums []int) int {
	count := 0
	candidate := 0

	// Boyer-Moore Voting Algorithm
	for _, num := range nums {
		if count == 0 {
			candidate = num
		}
		if num == candidate {
			count++
		} else {
			count--
		}
	}

	return candidate
}

func main() {
	nums := []int{2, 2, 1, 1, 1, 2, 2}
	fmt.Println("Majority element:", majorityElement(nums)) // Output: 2
}
