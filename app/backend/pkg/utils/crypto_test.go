package utils

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestEncryptDecryptString(t *testing.T) {
	// Use test-only placeholder key (exactly 16 bytes for AES-128); never use real secrets in tests.
	testKey := "testkey16bytes!!"
	tests := []struct {
		name    string
		key     string
		content string
	}{
		{
			name:    "Normal string",
			key:     testKey,
			content: "hello world",
		},
		{
			name:    "Empty string",
			key:     testKey,
			content: "",
		},
		{
			name:    "Special characters",
			key:     testKey,
			content: "!@#$%^&*()",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			encrypted := EncryptString(tt.key, tt.content)
			decrypted := DecryptString(tt.key, encrypted)
			assert.Equal(t, tt.content, decrypted)
		})
	}
}

func TestBase64StringOperations(t *testing.T) {
	tests := []struct {
		name    string
		content string
	}{
		{
			name:    "Normal string",
			content: "hello world",
		},
		{
			name:    "Empty string",
			content: "",
		},
		{
			name:    "Special characters",
			content: "!@#$%^&*()",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			encoded := Base64String(tt.content)
			decoded := DecodeBase64String(encoded)
			assert.Equal(t, tt.content, decoded)
		})
	}
}

func TestPasswordHashing(t *testing.T) {
	// Use test-only placeholder values; never use real passwords in tests.
	tests := []struct {
		name     string
		password string
	}{
		{
			name:     "Normal password",
			password: "test-password-placeholder",
		},
		{
			name:     "Empty password",
			password: "",
		},
		{
			name:     "Complex password",
			password: "test-complex-placeholder!",
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			hash, err := HashPassword(tt.password)
			assert.NoError(t, err)
			assert.NotEmpty(t, hash)

			// Verify password comparison
			isValid := ComparePassword(tt.password, hash)
			assert.True(t, isValid)

			// Verify wrong password fails
			isValid = ComparePassword("wrong-placeholder", hash)
			assert.False(t, isValid)
		})
	}
}
