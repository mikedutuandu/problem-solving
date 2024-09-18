package main

import "fmt"

func strStr(haystack string, needle string) int {
	if len(needle) == 0 {
		return 0
	}

	for i := 0; i <= len(haystack)-len(needle); i++ {
		if haystack[i:i+len(needle)] == needle {
			return i
		}
	}

	return -1
}

func strStr1(haystack string, needle string) int {
	i := 0
	j := 0
	count := 0
	output := -1
	for i < len(haystack) && j < len(needle) {
		if needle[j] == haystack[i] {
			j++
			i++
			count++
		} else {
			i = i - count + 1
			j = 0
			count = 0
		}

		if count == len(needle) {
			output = i - len(needle)
			break
		}
	}

	return output
}

func main() {
	haystack := "mississippi"
	needle := "issip"
	fmt.Print(strStr(haystack, needle))

}
