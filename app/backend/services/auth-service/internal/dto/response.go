package dto

import (
	"net/http"
	"strconv"

	"rmn-backend/pkg/apperror"
	"github.com/gin-gonic/gin"
)

type ErrorRes struct {
	Code    int    `json:"code"`
	Message string `json:"message"`
}

type Response struct {
	Code    string      `json:"code"`
	Message string      `json:"message"`
	Meta    interface{} `json:"meta"`
	Data    interface{} `json:"data"`
}

func SuccessResponse(c *gin.Context, status int, message string, data interface{}, meta ...interface{}) {
	metaData := make(map[string]interface{})
	if len(meta) > 0 {
		_, ok := meta[0].(map[string]interface{})
		if ok {
			metaData = meta[0].(map[string]interface{})
		}
	}
	c.JSON(status, Response{
		Code:    strconv.Itoa(status),
		Message: message,
		Data:    data,
		Meta:    metaData,
	})
}

func ErrorResponse(c *gin.Context, err *apperror.ErrorResponse, locale string) {
	message := err.GetErrorMessage(apperror.Locale(locale))
	c.JSON(err.Code, Response{
		Code:    strconv.Itoa(err.Code),
		Message: message,
		Data:    nil,
	})
}

func ValidationErrorResponse(c *gin.Context, errors map[string]string) {
	c.JSON(http.StatusBadRequest, Response{
		Code:    strconv.Itoa(http.StatusBadRequest),
		Message: "Validation error",
		Data:    errors,
	})
}
