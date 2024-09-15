package main

import (
	"fmt"
)

func main() {
	// Create a buffered channel with a capacity of 2
	channel := make(chan int, 2)

	// Send data into the channel (non-blocking since the buffer has space)
	channel <- 10
	channel <- 20

	// Receive data from the channel
	fmt.Println(<-channel) // Output: 10
	fmt.Println(<-channel) // Output: 20

	// The buffer is empty now, so sending or receiving would block
}
