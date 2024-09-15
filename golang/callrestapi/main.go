package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
)

// Define a struct to represent the API response
type ApiResponse struct {
	UserID    int    `json:"userId"`
	ID        int    `json:"id"`
	Title     string `json:"title"`
	Completed bool   `json:"completed"`
}

func main() {
	// Define the URL for the API endpoint
	url := "https://jsonplaceholder.typicode.com/todos/1"

	// Send the GET request
	response, err := http.Get(url)
	if err != nil {
		log.Fatalf("Error making GET request: %v", err)
	}
	defer response.Body.Close()

	// Read the response body
	body, err := io.ReadAll(response.Body)
	if err != nil {
		log.Fatalf("Error reading response body: %v", err)
	}

	// Parse the JSON response
	var apiResponse ApiResponse
	err = json.Unmarshal(body, &apiResponse)
	if err != nil {
		log.Fatalf("Error parsing JSON: %v", err)
	}

	// Print the result
	fmt.Printf("Response from API: %+v\n", apiResponse)
}
