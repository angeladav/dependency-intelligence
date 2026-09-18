.PHONY: run test docker-up docker-down docker-logs

run:
	go run ./cmd/api

test:
	go test ./...

docker-up:
	docker compose up -d

docker-down:
	docker compose down

docker-logs:
	docker compose logs -f
