FROM alpine:3.18

ARG PB_VERSION=0.22.22

RUN apk add --no-cache \
      unzip \
      ca-certificates \
      bash \
      wget \
    && wget -O /tmp/pb.zip https://github.com/pocketbase/pocketbase/releases/download/v${PB_VERSION}/pocketbase_${PB_VERSION}_linux_amd64.zip \
    && unzip /tmp/pb.zip -d /pb/ \
    && rm /tmp/pb.zip

# Copy the local pb_migrations dir into the image
COPY ./pb_migrations /pb/pb_migrations

# Copy the local pb_hooks dir into the image
COPY ./pb_hooks /pb/pb_hooks

EXPOSE 8090

# Health check to monitor the container's health
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --spider -q http://localhost:8090/api/health || exit 1

# Start PocketBase
CMD ["/pb/pocketbase", "serve", "--http=0.0.0.0:8090", "--dir", "/pb/pb_data"]