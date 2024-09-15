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
	//numbers <- 111 // this is 11 element > 10 then will block sender go routine and trigger receiver go routine

	fmt.Printf("OK")

}
