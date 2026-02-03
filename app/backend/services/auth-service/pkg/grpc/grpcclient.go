package grpcclient

import (
	"context"
	"strings"
	"sync"
	"time"

	"google.golang.org/grpc"
	"google.golang.org/grpc/backoff"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/credentials/insecure"
	"google.golang.org/grpc/keepalive"
)

// Options configures Dial behavior.
type Options struct {
	Creds             credentials.TransportCredentials
	Keepalive         keepalive.ClientParameters
	ConnectParams     *grpc.ConnectParams
	ServiceConfigJSON string
}

// Option functional option setter.
type Option func(*Options)

// WithTLS sets TLS credentials.
func WithTLS(creds credentials.TransportCredentials) Option {
	return func(o *Options) { o.Creds = creds }
}

// WithInsecure uses insecure transport credentials.
func WithInsecure() Option {
	return func(o *Options) { o.Creds = insecure.NewCredentials() }
}

// WithKeepalive sets client keepalive params.
func WithKeepalive(p keepalive.ClientParameters) Option {
	return func(o *Options) { o.Keepalive = p }
}

// WithConnectParams sets grpc.ConnectParams.
func WithConnectParams(cp grpc.ConnectParams) Option {
	return func(o *Options) { o.ConnectParams = &cp }
}

// WithServiceConfig provides a default service config JSON string.
func WithServiceConfig(json string) Option {
	return func(o *Options) { o.ServiceConfigJSON = json }
}

// NormalizeTarget ensures dns resolver is used when scheme is missing.
func NormalizeTarget(target string) string {
	if !strings.Contains(target, "://") {
		return "dns:///" + target
	}
	return target
}

var (
	connMu sync.Mutex
	conns  = make(map[string]*grpc.ClientConn)
)

// Dial creates (or reuses) a grpc.ClientConn with resilient defaults.
func Dial(ctx context.Context, target string, opts ...Option) (*grpc.ClientConn, error) {
	optsResolved := defaultOptions()
	for _, o := range opts {
		o(&optsResolved)
	}

	target = NormalizeTarget(target)

	connMu.Lock()
	if c, ok := conns[targetKey(target, &optsResolved)]; ok {
		connMu.Unlock()
		return c, nil
	}
	connMu.Unlock()

	dialOpts := []grpc.DialOption{
		grpc.WithTransportCredentials(optsResolved.Creds),
		grpc.WithKeepaliveParams(optsResolved.Keepalive),
	}
	if optsResolved.ConnectParams != nil {
		dialOpts = append(dialOpts, grpc.WithConnectParams(*optsResolved.ConnectParams))
	}
	if optsResolved.ServiceConfigJSON != "" {
		dialOpts = append(dialOpts, grpc.WithDefaultServiceConfig(optsResolved.ServiceConfigJSON))
	}

	// Use grpc.NewClient to match existing codebase usage.
	conn, err := grpc.NewClient(target, dialOpts...)
	if err != nil {
		return nil, err
	}

	connMu.Lock()
	conns[targetKey(target, &optsResolved)] = conn
	connMu.Unlock()
	return conn, nil
}

func defaultOptions() Options {
	return Options{
		Creds: insecure.NewCredentials(),
		Keepalive: keepalive.ClientParameters{
			Time:                30 * time.Second,
			Timeout:             10 * time.Second,
			PermitWithoutStream: true,
		},
		ConnectParams: &grpc.ConnectParams{
			Backoff:           backoff.DefaultConfig,
			MinConnectTimeout: 5 * time.Second,
		},
	}
}

func targetKey(target string, o *Options) string {
	// Currently only target is used as key. If in future multiple creds per target are needed,
	// extend this key accordingly.
	return target
}
