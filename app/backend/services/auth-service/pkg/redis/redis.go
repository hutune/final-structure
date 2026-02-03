package redis

import (
	"context"
	"encoding/json"
	"fmt"
	"rmn-backend/services/auth-service/pkg/config"
	"time"

	"github.com/redis/go-redis/v9"
)

type RedisClient struct {
	client *redis.Client
}

func InitRedis(cfg config.RedisConfig) (*RedisClient, error) {
	var client *redis.Client
	if cfg.Password == "" {
		client = redis.NewClient(&redis.Options{
			Addr: fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
			DB:   0,
		})
	} else {
		client = redis.NewClient(&redis.Options{
			Addr:     fmt.Sprintf("%s:%d", cfg.Host, cfg.Port),
			Password: cfg.Password,
			DB:       0,
		})
	}

	if err := client.Ping(context.Background()).Err(); err != nil {
		return nil, err
	}

	return &RedisClient{
		client: client,
	}, nil
}

func (w *RedisClient) Close() error {
	return w.client.Close()
}

func (w *RedisClient) Set(ctx context.Context, key string, value interface{}, expiration time.Duration) error {
	jsonValue, err := json.Marshal(value)
	if err != nil {
		return err
	}
	return w.client.Set(ctx, key, string(jsonValue), expiration).Err()
}

func (w *RedisClient) Get(ctx context.Context, key string) (string, error) {
	return w.client.Get(ctx, key).Result()
}

func (w *RedisClient) GetByBytes(ctx context.Context, key string) ([]byte, error) {
	return w.client.Get(ctx, key).Bytes()
}

func (w *RedisClient) GetByTime(ctx context.Context, key string) (time.Time, error) {
	return w.client.Get(ctx, key).Time()
}

func (w *RedisClient) Del(ctx context.Context, keys ...string) error {
	return w.client.Del(ctx, keys...).Err()
}

func (w *RedisClient) Sub(ctx context.Context, channel string) *redis.PubSub {
	return w.client.Subscribe(ctx, channel)
}

func (w *RedisClient) Pub(ctx context.Context, channel string, message interface{}) error {
	if err := w.client.Publish(ctx, channel, message).Err(); err != nil {
		return fmt.Errorf("failed to publish message: %w", err)
	}
	return nil
}

func (w *RedisClient) SAdd(ctx context.Context, key string, members ...interface{}) error {
	return w.client.SAdd(ctx, key, members...).Err()
}

func (w *RedisClient) SRem(ctx context.Context, key string, members ...interface{}) error {
	return w.client.SRem(ctx, key, members).Err()
}

func (w *RedisClient) IsRoomMember(ctx context.Context, roomID string, userID string) (bool, error) {
	return w.client.SIsMember(ctx, roomID, userID).Result()
}

func (w *RedisClient) IncrBy(ctx context.Context, key string, value int64) (int64, error) {
	return w.client.IncrBy(ctx, key, value).Result()
}

func (w *RedisClient) CheckKeyExist(ctx context.Context, key string) (bool, error) {
	exist, err := w.client.Exists(ctx, key).Result()
	if err != nil {
		return false, err
	}
	return exist > 0, nil
}
