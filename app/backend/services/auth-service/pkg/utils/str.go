package utils

import (
	"regexp"
	"strconv"
	"strings"
)

func IsScreamingSnakeCase(s string) bool {
	pattern := `^[A-Z0-9]+(_[A-Z0-9]+)*$`
	matched, _ := regexp.MatchString(pattern, s)
	return matched && !strings.ContainsAny(s, "abcdefghijklmnopqrstuvwxyz")
}

func IsSnakeCase(s string) bool {
	pattern := `^[a-z0-9]+(_[a-z0-9]+)*$`
	matched, _ := regexp.MatchString(pattern, s)
	return matched
}

// ParseFloat converts a string to float64, returns 0 if conversion fails
func ParseFloat(s string) float64 {
	if s == "" {
		return 0
	}
	f, err := strconv.ParseFloat(strings.TrimSpace(s), 64)
	if err != nil {
		return 0
	}
	return f
}

// ParseInt converts a string to int, returns 0 if conversion fails
func ParseInt(s string) int {
	if s == "" {
		return 0
	}
	i, err := strconv.Atoi(strings.TrimSpace(s))
	if err != nil {
		return 0
	}
	return i
}
