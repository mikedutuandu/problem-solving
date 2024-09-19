package main

/*
Type Definition:
rune is actually a type alias for int32.
This means that a rune in Go is a 32-bit integer value capable of holding any valid Unicode code point.
type rune = int32

Why rune?
Go uses rune to make it clear when you're dealing with Unicode characters rather than just integer values. By using rune, Go programmers can express intent more clearly, especially when working with text and characters.

UTF-8 Encoding:
Strings in Go are encoded in UTF-8, which is a variable-length encoding. A string can contain multiple runes, and each rune may take 1 to 4 bytes to represent in UTF-8.

String and Rune:
In Go, strings are collections of bytes, but since strings are encoded in UTF-8, a string can contain multiple runes (characters).
You can convert a string to a slice of rune to work with individual Unicode characters.

Example:
s := "hello"
runes := []rune(s)  // Converts string to a slice of runes
fmt.Println(runes)   // Output: [104 101 108 108 111]
*/
