package app

import (
	"fmt"
	"rmn-backend/services/auth-service/internal/app/routes"
	"rmn-backend/services/auth-service/internal/common"
	exampleLogic "rmn-backend/services/auth-service/internal/logic/example"
	"rmn-backend/services/auth-service/internal/repositories"
	"rmn-backend/services/auth-service/internal/services"
)

// Server represents the server
type Server struct {
	ctx *common.App
}

func NewServer(ctx *common.App) *Server {
	// Setup services
	RegisterServices(ctx)
	return &Server{ctx: ctx}
}

// Run starts the server
func (s *Server) Run() {
	router := &routes.Router{}

	// Setup router
	err := router.NewRouter(s.ctx)
	if err != nil {
		panic(fmt.Errorf("failed to initialize router: %w", err))
	}
	router.SetupRouter(s.ctx)

	router.Run(fmt.Sprintf(":%d", s.ctx.Cfg.HttpServer.Port))
}

func RegisterServices(ctx *common.App) {
	// Setup repositories
	exampleRepo := repositories.NewExampleRepository(ctx)

	// Setup logic
	exampleLogic := exampleLogic.NewExampleLogic(exampleRepo)

	// Setup services
	services.RegisterExample(exampleLogic)
}
