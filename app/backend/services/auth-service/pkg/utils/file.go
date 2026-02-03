package utils

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"slices"
	"strings"

	"rmn-backend/pkg/logger"
)

const ExcelContentType = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"

// ValidExcelContentTypes contains all acceptable content types for Excel files
var ValidExcelContentTypes = []string{
	"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", // Standard XLSX MIME type
	"application/zip",          // Common for cloud storage (XLSX is essentially a ZIP file)
	"application/vnd.ms-excel", // Legacy XLS format
	"application/octet-stream", // Generic binary (sometimes used by cloud storage)
}

func CheckFileByHead(url string, logger ...logger.ILogger) (size int64, contentType string, err error) {
	httpClient := &http.Client{}
	fileReq, err := http.NewRequest("HEAD", url, nil)
	if err != nil {
		return 0, "", err
	}
	resp, err := httpClient.Do(fileReq)
	if err != nil {
		return 0, "", err
	}
	defer resp.Body.Close()
	return resp.ContentLength, resp.Header.Get("Content-Type"), nil
}

// progressReader wraps an io.Reader to track download progress
type progressReader struct {
	reader io.Reader
	total  int64
	update func(int64)
}

func (pr *progressReader) Read(p []byte) (n int, err error) {
	n, err = pr.reader.Read(p)
	pr.update(int64(n))
	return
}

func DownloadPublicFile(url string) (filePath string, err error) {
	// Create a temporary file
	tmpFile, err := os.CreateTemp("", "excel_*.xlsx")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %w", err)
	}
	defer tmpFile.Close()

	// Make HTTP GET request
	resp, err := http.Get(url)
	if err != nil {
		return "", fmt.Errorf("failed to download file: %w", err)
	}
	defer resp.Body.Close()

	// Check if the response is successful
	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("bad status: %s", resp.Status)
	}

	// Get the total size of the file (if provided by the server)
	totalSize := resp.ContentLength
	if totalSize <= 0 {
		log.Println("Content length not provided, progress tracking unavailable")
	}

	// Create a reader for progress tracking
	var written int64

	reader := &progressReader{
		reader: resp.Body,
		total:  totalSize,
		update: func(n int64) {
			written += n
			if totalSize > 0 {
				fmt.Printf("\rDownloaded: %.2f%% (%d/%d bytes)", float64(written)/float64(totalSize)*100, written, totalSize)
			} else {
				fmt.Printf("\rDownloaded: %d bytes", written)
			}
		},
	}

	// Write the response body to the temporary file
	_, err = io.Copy(tmpFile, reader)
	if err != nil {
		return "", fmt.Errorf("failed to write to temp file: %w", err)
	}
	fmt.Println("\nDownload complete")

	return tmpFile.Name(), nil
}

// validateFile checks if the file type and size are valid
func ValidateTypeAndSizeFile(ImportFileUrl string, maxSize int64, allowedContentType string) error {
	// Check file size and type
	size, contentType, err := CheckFileByHead(ImportFileUrl)
	if err != nil {
		return fmt.Errorf("failed to download file: %w", err)
	}
	if size > maxSize {
		return fmt.Errorf("file too large: %d > %d", size, maxSize)
	}

	// Check if content type is valid for Excel files
	if !isValidExcelContentType(contentType) {
		fmt.Printf("Content type '%s' is invalid. Expected one of: %v\n", contentType, ValidExcelContentTypes)
		return fmt.Errorf("file type invalid: %s", contentType)
	}
	return nil
}

// IsValidExcelFile checks if the given content type is valid for Excel files
// This function can be used by other parts of the code to validate Excel files consistently
func IsValidExcelFile(contentType string) bool {
	return isValidExcelContentType(contentType)
}

// isValidExcelContentType checks if the given content type is valid for Excel files
func isValidExcelContentType(contentType string) bool {
	// Normalize content type by removing charset and other parameters
	contentType = strings.Split(contentType, ";")[0]
	contentType = strings.TrimSpace(contentType)

	return slices.Contains(ValidExcelContentTypes, contentType)
}
