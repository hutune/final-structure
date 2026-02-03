package errors

import "errors"

var (
	// Common errors
	ErrInternalServerError = errors.New("INTERNAL_SERVER_ERROR")
	ErrAlreadyExists       = errors.New("ALREADY_EXISTS")
	ErrNotFound            = errors.New("NOT_FOUND")
	ErrUnprocessableEntity = errors.New("UNPROCESSABLE_ENTITY")
	ErrUnauthorized        = errors.New("UNAUTHORIZED")
	// Auth
	ErrTokenExpired = errors.New("TOKEN_EXPIRED")
)
