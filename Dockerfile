# ---------- Stage 1: Build ----------
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Copy go.mod truoc de tan dung cache layer khi dependencies khong doi
COPY go.mod ./
# Neu co go.sum thi copy them: COPY go.mod go.sum ./
RUN go mod download 2>/dev/null || true

COPY . .

# Build binary tinh (static), tat CGO de chay duoc tren alpine/scratch
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server .

# ---------- Stage 2: Runtime ----------
FROM alpine:3.19

RUN apk --no-cache add ca-certificates

WORKDIR /app
COPY --from=builder /app/server .

EXPOSE 8080

ENTRYPOINT ["/app/server"]
