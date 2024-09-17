package main

import (
	"fmt"
)

func maxProfit(prices []int) int {
	// Initialize variables to track the minimum price and maximum profit
	minPrice := 1000000000000000
	maxProfit := 0

	// Iterate through the prices array
	for _, price := range prices {
		if price < minPrice {
			minPrice = price
		}

		profit := price - minPrice
		if profit > maxProfit {
			maxProfit = profit
		}
	}

	return maxProfit
}

func main() {
	nums := []int{1, 2, 4}
	fmt.Println("Majority element:", maxProfit(nums)) // Output: 2
}
