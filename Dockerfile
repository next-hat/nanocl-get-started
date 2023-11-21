# stage 1 - Setup cargo-chef
FROM --platform=$BUILDPLATFORM rust:1.74.0-alpine3.17 as planner

WORKDIR /app
RUN apk add gcc g++ make
RUN cargo install cargo-chef --locked
COPY ./Cargo.toml ./Cargo.toml
COPY ./Cargo.lock ./Cargo.lock
RUN cargo chef prepare --recipe-path recipe.json

# state 2 - Cook our dependencies
FROM --platform=$BUILDPLATFORM rust:1.74.0-alpine3.17 as cacher

WORKDIR /app
COPY --from=planner /usr/local/cargo/bin/cargo-chef /usr/local/cargo/bin/cargo-chef
COPY --from=planner /app .
RUN apk add musl-dev
ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN export ARCH=$(uname -m) \
  && cargo chef cook --release --target=$ARCH-unknown-linux-musl --recipe-path recipe.json

# stage 3 - Build our project
FROM --platform=$BUILDPLATFORM rust:1.74.0-alpine3.17 as builder

## Build our metrs daemon binary
WORKDIR /app
COPY --from=cacher /usr/local/cargo /usr/local/cargo
COPY --from=cacher /app .
COPY ./src ./src
RUN apk add musl-dev git upx
ENV RUSTFLAGS="-C target-feature=+crt-static"
RUN export ARCH=$(uname -m) \
  && cargo build --release --target=$ARCH-unknown-linux-musl

## Compress the binary
RUN export ARCH=$(uname -m) \
  && upx --lzma --best /app/target/$ARCH-unknown-linux-musl/release/nanocl-get-started \
  && cp /app/target/$ARCH-unknown-linux-musl/release/nanocl-get-started /bin/nanocl-get-started

# stage 4 - Create runtime image
FROM --platform=$BUILDPLATFORM scratch

## Copy the binary
COPY --from=builder /bin/nanocl-get-started /bin/nanocl-get-started

LABEL org.opencontainers.image.source https://github.com/nxthat/nanocl-get-started
LABEL org.opencontainers.image.description Nanocl get started image

EXPOSE 9000

## Set entrypoint
ENTRYPOINT ["/bin/nanocl-get-started"]
