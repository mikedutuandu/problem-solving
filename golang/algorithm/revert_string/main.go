package main

import "fmt"

func reverseString(s string) string {
	/*
		In Go, strings are immutable, meaning that once a string is created, you cannot change its contents.
		That's why you're unable to directly assign str[i] = str[j] as you would in an array or a slice.

		SOLUTION:
		If you need to modify a string, you need to convert the string to a slice of bytes (or rune, if you're dealing with Unicode),
		make the modification, and then convert it back to a string.
	*/
	r := []rune(s)
	for i, j := 0, len(r)-1; i < j; i, j = i+1, j-1 {
		r[i], r[j] = r[j], r[i]
	}
	return string(r)
}

func reverseString1(s string) string {

	r := []rune(s)
	i := 0
	j := len(r) - 1
	for i < j {
		r[i], r[j] = r[j], r[i]
		i++
		j--
	}
	return string(r)
}

func main() {
	str := "hello world"

	fmt.Println(reverseString1(str))
}
