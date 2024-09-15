package main

import (
	"fmt"
	"time"
)

// The select statement waits for either channel1 or channel2 to send a message.
// The first one to send will trigger the corresponding case.
// If neither sends a message within 2 seconds, the time.After case triggers, simulating a timeout.
func sendValues(data string, channel chan string) {
	time.Sleep(1 * time.Second)
	channel <- data
}

func main() {
	channel1 := make(chan string)
	channel2 := make(chan string)

	go sendValues("m1", channel1)
	go sendValues("m2", channel2)

	// Use select to wait for either channel to send a message
	for {
		select {
		case msg1 := <-channel1:
			fmt.Println("Received:", msg1)
		case msg2 := <-channel2:
			fmt.Println("Received:", msg2)
		case <-time.After(2 * time.Second): // Timeout case
			fmt.Println("Timeout")
		}
	}
}
