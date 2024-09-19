package main

import (
	"github.com/labstack/echo/v4"
	"net/http"
	"strconv"
)

/*
 RESTful API:
Question: Explain what REST is and how it is different from SOAP. How would you design a RESTful API for an e-commerce application?

Answer: REST (Representational State Transfer) is an architectural style for designing networked applications. It relies on stateless, client-server communication and typically uses HTTP protocols for interaction. RESTful APIs are commonly used to interact with web services. Unlike SOAP, which is a protocol with a strict standard for message format and transmission, REST is more flexible, supporting different data formats like JSON, XML, and plain text. RESTful APIs use standard HTTP methods like GET, POST, PUT, and DELETE to perform CRUD (Create, Read, Update, Delete) operations.

To design a RESTful API for an e-commerce application, we can structure it as follows:

GET /products: Retrieve a list of all products.
GET /products/{id}: Retrieve details of a specific product by ID.
POST /orders: Create a new order.
GET /orders/{id}: Retrieve details of a specific order.
This structure ensures simplicity, scalability, and adherence to REST principles.
*/

/*
In REST, the term stateless refers to the idea that each request from a client to a server must contain all the information the server needs to understand and process the request.
The server does not store any information about the client's previous requests (i.e., no session data is saved between requests).

Benefits of statelessness:
Scalability: Since the server doesn't need to track session information, it's easier to distribute requests across multiple servers.
Simplicity: Each request is independent, making the system simpler to design and debug.
*/

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
