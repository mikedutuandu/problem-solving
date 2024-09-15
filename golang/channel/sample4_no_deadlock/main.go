package main

import "fmt"

func main() {
	channel := make(chan int)

	// Start a goroutine to receive data from the channel
	go func() {
		fmt.Println(<-channel)
	}()

	// Send data into the channel
	channel <- 10
}
