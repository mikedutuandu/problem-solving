package main

import "fmt"

func longestCommonPrefix(strs []string) string {
	if len(strs) == 1 {
		return strs[0]
	}

	i := 0
	j := 0
	count := 0
	output := ""

	for i < len(strs)-1 {
		str := strs[i]
		nextStr := strs[i+1]

		if len(str) == 0 || len(str) <= j || len(nextStr) <= j {
			return output
		}

		if str[j] == nextStr[j] {
			count++
		}

		i++

		if count == len(strs)-1 {
			output = output + string(str[j])

			i = 0
			count = 0
			j++
		}

	}

	return output

}

func main() {
	s := []string{"flower", "flow", "flight"}

	fmt.Print(longestCommonPrefix(s))

}
