package dto

// ExampleCreateRequest represents the request DTO for creating an example
type ExampleCreateRequest struct {
	Name        string `json:"name" binding:"required"`
	Description string `json:"description"`
	Status      string `json:"status"`
}

// ExampleUpdateRequest represents the request DTO for updating an example
type ExampleUpdateRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	Status      string `json:"status"`
}

// ExampleResponse represents the response DTO for an example
type ExampleResponse struct {
	ID          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	Status      string `json:"status"`
	CreatedAt   string `json:"created_at"`
	UpdatedAt   string `json:"updated_at"`
}
