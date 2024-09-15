package main

import (
	"github.com/labstack/echo/v4"
	"net/http"
	"strconv"
)

// Book struct represents a book resource
type Book struct {
	ID     int    `json:"id"`
	Title  string `json:"title"`
	Author string `json:"author"`
}

var books = []Book{}
var nextID = 1

// Get all books
func getBooks(c echo.Context) error {
	return c.JSON(http.StatusOK, books)
}

// Get a single book by ID
func getBook(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid book ID"})
	}

	for _, book := range books {
		if book.ID == id {
			return c.JSON(http.StatusOK, book)
		}
	}

	return c.JSON(http.StatusNotFound, echo.Map{"message": "Book not found"})
}

// Create a new book
func createBook(c echo.Context) error {
	book := new(Book)
	if err := c.Bind(book); err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Failed to parse request"})
	}

	book.ID = nextID
	nextID++
	books = append(books, *book)
	return c.JSON(http.StatusCreated, book)
}

// Update an existing book
func updateBook(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid book ID"})
	}

	for i, book := range books {
		if book.ID == id {
			if err := c.Bind(&books[i]); err != nil {
				return c.JSON(http.StatusBadRequest, echo.Map{"message": "Failed to parse request"})
			}
			return c.JSON(http.StatusOK, books[i])
		}
	}

	return c.JSON(http.StatusNotFound, echo.Map{"message": "Book not found"})
}

// Delete a book by ID
func deleteBook(c echo.Context) error {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		return c.JSON(http.StatusBadRequest, echo.Map{"message": "Invalid book ID"})
	}

	for i, book := range books {
		if book.ID == id {
			books = append(books[:i], books[i+1:]...) // Remove the book from the slice
			return c.NoContent(http.StatusNoContent)
		}
	}

	return c.JSON(http.StatusNotFound, echo.Map{"message": "Book not found"})
}

func main() {
	// Create a new Echo instance
	e := echo.New()

	// Define routes for CRUD operations
	e.GET("/books", getBooks)          // Get all books
	e.GET("/books/:id", getBook)       // Get a book by ID
	e.POST("/books", createBook)       // Create a new book
	e.PUT("/books/:id", updateBook)    // Update an existing book by ID
	e.DELETE("/books/:id", deleteBook) // Delete a book by ID

	// Start the server on port 8080
	e.Logger.Fatal(e.Start(":8080"))
}
