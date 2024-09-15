package main

import (
	"fmt"
)

/*
Unbuffered channels block the sender until there is a receiver ready to receive the data.
In this case, the line channel <- 10 tries to send 10 to the channel,
but there is no goroutine or function waiting to receive it yet.Since Go channels
are synchronous without a buffer, the program deadlocks because the sender cannot
proceed until a receiver is available.

*/

func main() {
	// Create an unbuffered channel (no capacity specified)
	channel := make(chan int)

	// This will block because there is no receiver ready
	channel <- 10

	// Receive data from the channel
	fmt.Println(<-channel) // Output: 10
}
