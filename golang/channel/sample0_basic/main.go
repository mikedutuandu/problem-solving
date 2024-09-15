package main

import (
	"fmt"
	"time"
)

// Your program does not deadlock because you are using a goroutine to send data into the channel,
// while the main function receives from the channel.

// Function to be run as a goroutine
func printNumbers(channel chan int) {
	for i := 1; i <= 5; i++ {
		channel <- i // Send numbers to the channel
		time.Sleep(500 * time.Millisecond)
	}
	close(channel) // Close the channel when done
}

func main() {
	// Create a new channel of type int
	numbers := make(chan int)

	// Start the goroutine
	go printNumbers(numbers)

	// Receive values from the channel
	for num := range numbers {
		fmt.Println("Received:", num)
	}

	fmt.Println("All numbers received, main function exits.")
}
