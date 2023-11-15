FROM --platform=$BUILDPLATFORM rust:1.73 AS buildbase
RUN rustup target add wasm32-wasi
WORKDIR /src

FROM --platform=$BUILDPLATFORM buildbase AS buildstage
RUN apt-get update && apt-get install ca-certificates -y
COPY . .
RUN --mount=type=cache,target=/usr/local/cargo/git/db \
    --mount=type=cache,target=/usr/local/cargo/registry/cache \
    --mount=type=cache,target=/usr/local/cargo/registry/index \
    cargo build --target wasm32-wasi --release

FROM scratch
COPY --link --from=buildstage /src/target/wasm32-wasi/release/slight_server_test.wasm app.wasm
COPY --link --from=buildstage /src/slightfile.toml slightfile.toml
COPY --link --from=buildstage /etc/ssl /etc/ssl

CMD [ "/" ]
