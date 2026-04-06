FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y curl openjdk-11-jdk unzip g++ gcc

# 下载 Bazel 8.1.0 安装脚本
RUN curl -LO https://github.com/bazelbuild/bazel/releases/download/8.1.0/bazel-8.1.0-installer-linux-x86_64.sh \
    && chmod +x bazel-8.1.0-installer-linux-x86_64.sh \
    && ./bazel-8.1.0-installer-linux-x86_64.sh --prefix=/usr/local \
    && rm bazel-8.1.0-installer-linux-x86_64.sh

WORKDIR /build

COPY . .

RUN --mount=type=cache,target=/root/.cache/bazel \
    bazel build :hello \
    && mkdir -p /build/output \
    && cp bazel-bin/hello /build/output/hello


FROM debian:bookworm-slim
WORKDIR /app
COPY --from=builder /build/output/hello /app/hello

CMD ["hello"]
