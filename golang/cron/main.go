package main

import (
	"fmt"
	"github.com/robfig/cron/v3"
	"time"
)

// Define multiple job functions
func job1() {
	fmt.Println("Job 1 executed at:", time.Now().Format(time.RFC3339))
}

func job2() {
	fmt.Println("Job 2 executed at:", time.Now().Format(time.RFC3339))
}

func main() {
	// Create a new cron instance
	c := cron.New()

	// Schedule job1 to run every minute
	c.AddFunc("* * * * *", job1)

	// Schedule job2 to run every 5 minutes
	c.AddFunc("*/5 * * * *", job2)

	// Start the cron scheduler
	c.Start()

	// Block the main goroutine
	select {}
}
