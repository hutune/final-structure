package logger

import (
	"context"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/mock"
	"go.opentelemetry.io/otel/trace"
)

func TestNewLogger(t *testing.T) {
	tests := []struct {
		name    string
		config  Config
		wantErr bool
	}{
		{
			name: "valid config",
			config: Config{
				Service: "test-service",
				Level:   InfoLv,
			},
			wantErr: false,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			zl, err := NewLogger(tt.config)
			if tt.wantErr {
				assert.Error(t, err)
				return
			}
			assert.NoError(t, err)
			assert.NotNil(t, zl)
		})
	}
}

func TestLogLevels(t *testing.T) {
	zl, err := NewLogger(Config{Service: "test-service", Level: DebugLv})
	assert.NoError(t, err)
	ctx := context.Background()

	// Smoke test: ensure all levels can be called without panic
	zl.Debug(ctx, "debug message", "key", "value")
	zl.Info(ctx, "info message", "key", "value")
	zl.Warn(ctx, "warn message", "key", "value")
	zl.Error(ctx, "error message", "key", "value")
}

// MockLogger is a mock implementation of ILogger for testing opentelemetry decorator
type MockLogger struct {
	mock.Mock
}

func (m *MockLogger) Debug(ctx context.Context, msg string, fields ...interface{}) {
	m.Called(ctx, msg, fields)
}

func (m *MockLogger) Info(ctx context.Context, msg string, fields ...interface{}) {
	m.Called(ctx, msg, fields)
}

func (m *MockLogger) Warn(ctx context.Context, msg string, fields ...interface{}) {
	m.Called(ctx, msg, fields)
}

func (m *MockLogger) Error(ctx context.Context, msg string, fields ...interface{}) {
	m.Called(ctx, msg, fields)
}

func (m *MockLogger) Fatal(ctx context.Context, msg string, fields ...interface{}) {
	m.Called(ctx, msg, fields)
}

func (m *MockLogger) With(fields ...interface{}) ILogger {
	args := m.Called(fields)
	return args.Get(0).(ILogger)
}

func TestOpenTelemetryDecorator(t *testing.T) {
	tests := []struct {
		name      string
		level     string
		msg       string
		fields    []interface{}
		withTrace bool
	}{
		{
			name:      "Debug with trace",
			level:     "debug",
			msg:       "debug message",
			fields:    []interface{}{"key", "value"},
			withTrace: true,
		},
		{
			name:      "Info without trace",
			level:     "info",
			msg:       "info message",
			fields:    []interface{}{"key", "value"},
			withTrace: false,
		},
		{
			name:      "Error with fields",
			level:     "error",
			msg:       "error message",
			fields:    []interface{}{"error", "test error"},
			withTrace: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			mockLogger := new(MockLogger)
			decorator := NewOpenTelemetryDecorator()
			decoratedLogger := decorator.Decorate(mockLogger).(*openTelemetryLogger)

			ctx := context.Background()
			if tt.withTrace {
				sc := trace.NewSpanContext(trace.SpanContextConfig{
					TraceID: trace.TraceID{0x01},
					SpanID:  trace.SpanID{0x01},
				})
				ctx = trace.ContextWithSpanContext(ctx, sc)
			}

			// Decorator may append trace_id/span_id to fields when withTrace is true, so use mock.Anything for fields
			switch tt.level {
			case "debug":
				mockLogger.On("Debug", mock.Anything, tt.msg, mock.Anything).Return()
				decoratedLogger.Debug(ctx, tt.msg, tt.fields...)
			case "info":
				mockLogger.On("Info", mock.Anything, tt.msg, mock.Anything).Return()
				decoratedLogger.Info(ctx, tt.msg, tt.fields...)
			case "warn":
				mockLogger.On("Warn", mock.Anything, tt.msg, mock.Anything).Return()
				decoratedLogger.Warn(ctx, tt.msg, tt.fields...)
			case "error":
				mockLogger.On("Error", mock.Anything, tt.msg, mock.Anything).Return()
				decoratedLogger.Error(ctx, tt.msg, tt.fields...)
			}

			mockLogger.AssertExpectations(t)
		})
	}

	t.Run("With method", func(t *testing.T) {
		mockLogger := new(MockLogger)
		decorator := NewOpenTelemetryDecorator()
		decoratedLogger := decorator.Decorate(mockLogger)

		fields := []interface{}{"key", "value"}
		mockLogger.On("With", fields).Return(mockLogger)

		newLogger := decoratedLogger.With(fields...)
		assert.NotNil(t, newLogger)
		mockLogger.AssertExpectations(t)
	})
}
