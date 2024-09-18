package main

import "fmt"

func lengthOfLastWord(s string) int {
	n := len(s)
	count := 0
	for i := n - 1; i >= 0; i-- {
		if s[i] != ' ' {
			count++
		}

		if count > 0 && i-1 >= 0 && s[i-1] == ' ' {
			break
		}
	}

	return count
}

func main() {
	s := "   fly me   to   the moon  "

	fmt.Print(lengthOfLastWord(s))

}
