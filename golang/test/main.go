package main

import "fmt"

func main() {
	numbers := make(chan int, 10)

	go func() {
		for num := range numbers {
			fmt.Println("Received:", num)
		}
	}()

	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 1
	numbers <- 111
	numbers <- 111

	fmt.Printf("OK")

}
