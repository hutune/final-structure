package handler

import (
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"

	"rmn-backend/pkg/logger"
	"rmn-backend/services/auth-service/internal/dto"
	"rmn-backend/services/auth-service/internal/models"
	"rmn-backend/services/auth-service/internal/services"
)

type ExampleHandler struct {
	logger *logger.ZeroLogger
}

func NewExampleHandler(l *logger.ZeroLogger) *ExampleHandler {
	return &ExampleHandler{logger: l}
}

func (h *ExampleHandler) Create(c *gin.Context) {
	var req dto.ExampleCreateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.ValidationErrorResponse(c, map[string]string{"error": err.Error()})
		return
	}

	example := &models.Example{
		Name:        req.Name,
		Description: req.Description,
		Status:      req.Status,
	}

	logic := services.GetExampleLogic()
	if err := logic.Create(example); err != nil {
		h.logger.Error(c.Request.Context(), "failed to create example", "error", err)
		c.JSON(http.StatusInternalServerError, dto.Response{
			Code:    strconv.Itoa(http.StatusInternalServerError),
			Message: "Failed to create example",
			Data:    nil,
		})
		return
	}

	response := dto.ExampleResponse{
		ID:          example.ID.String(),
		Name:        example.Name,
		Description: example.Description,
		Status:      example.Status,
		CreatedAt:   example.CreatedAt.Format(time.RFC3339),
		UpdatedAt:   example.UpdatedAt.Format(time.RFC3339),
	}

	dto.SuccessResponse(c, http.StatusCreated, "Example created successfully", response)
}

func (h *ExampleHandler) GetByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		dto.ValidationErrorResponse(c, map[string]string{"id": "Invalid ID format"})
		return
	}

	logic := services.GetExampleLogic()
	example, err := logic.GetByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, dto.Response{
			Code:    strconv.Itoa(http.StatusNotFound),
			Message: "Example not found",
			Data:    nil,
		})
		return
	}

	response := dto.ExampleResponse{
		ID:          example.ID.String(),
		Name:        example.Name,
		Description: example.Description,
		Status:      example.Status,
		CreatedAt:   example.CreatedAt.Format(time.RFC3339),
		UpdatedAt:   example.UpdatedAt.Format(time.RFC3339),
	}

	dto.SuccessResponse(c, http.StatusOK, "Example retrieved successfully", response)
}

func (h *ExampleHandler) GetAll(c *gin.Context) {
	limitStr := c.DefaultQuery("limit", "10")
	offsetStr := c.DefaultQuery("offset", "0")

	limit, err := strconv.Atoi(limitStr)
	if err != nil || limit < 1 {
		limit = 10
	}

	offset, err := strconv.Atoi(offsetStr)
	if err != nil || offset < 0 {
		offset = 0
	}

	logic := services.GetExampleLogic()
	examples, total, err := logic.GetAll(limit, offset)
	if err != nil {
		h.logger.Error(c.Request.Context(), "failed to get examples", "error", err)
		c.JSON(http.StatusInternalServerError, dto.Response{
			Code:    strconv.Itoa(http.StatusInternalServerError),
			Message: "Failed to get examples",
			Data:    nil,
		})
		return
	}

	var responses []dto.ExampleResponse
	for _, example := range examples {
		responses = append(responses, dto.ExampleResponse{
			ID:          example.ID.String(),
			Name:        example.Name,
			Description: example.Description,
			Status:      example.Status,
			CreatedAt:   example.CreatedAt.Format(time.RFC3339),
			UpdatedAt:   example.UpdatedAt.Format(time.RFC3339),
		})
	}

	meta := map[string]interface{}{
		"total":  total,
		"limit":  limit,
		"offset": offset,
	}

	dto.SuccessResponse(c, http.StatusOK, "Examples retrieved successfully", responses, meta)
}

func (h *ExampleHandler) Update(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		dto.ValidationErrorResponse(c, map[string]string{"id": "Invalid ID format"})
		return
	}

	var req dto.ExampleUpdateRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		dto.ValidationErrorResponse(c, map[string]string{"error": err.Error()})
		return
	}

	example := &models.Example{
		BaseModel: models.BaseModel{
			ID: id,
		},
		Name:        req.Name,
		Description: req.Description,
		Status:      req.Status,
	}

	logic := services.GetExampleLogic()
	if err := logic.Update(example); err != nil {
		h.logger.Error(c.Request.Context(), "failed to update example", "error", err)
		c.JSON(http.StatusNotFound, dto.Response{
			Code:    strconv.Itoa(http.StatusNotFound),
			Message: "Example not found",
			Data:    nil,
		})
		return
	}

	updated, _ := logic.GetByID(id)
	response := dto.ExampleResponse{
		ID:          updated.ID.String(),
		Name:        updated.Name,
		Description: updated.Description,
		Status:      updated.Status,
		CreatedAt:   updated.CreatedAt.Format(time.RFC3339),
		UpdatedAt:   updated.UpdatedAt.Format(time.RFC3339),
	}

	dto.SuccessResponse(c, http.StatusOK, "Example updated successfully", response)
}

func (h *ExampleHandler) Delete(c *gin.Context) {
	idStr := c.Param("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		dto.ValidationErrorResponse(c, map[string]string{"id": "Invalid ID format"})
		return
	}

	logic := services.GetExampleLogic()
	if err := logic.Delete(id); err != nil {
		h.logger.Error(c.Request.Context(), "failed to delete example", "error", err)
		c.JSON(http.StatusNotFound, dto.Response{
			Code:    strconv.Itoa(http.StatusNotFound),
			Message: "Example not found",
			Data:    nil,
		})
		return
	}

	dto.SuccessResponse(c, http.StatusOK, "Example deleted successfully", nil)
}
