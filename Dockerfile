ARG SWIFT_VERSION=5.4
ARG SWIFT_UBUNTU_RELEASE=bionic

FROM alpine/git:latest AS cloner
ENV SWIFTLINT_REVISION="master"
WORKDIR /swiftlint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git

FROM swift:${SWIFT_VERSION}-${SWIFT_UBUNTU_RELEASE} AS builder
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libxml2-dev && \
    rm -r /var/lib/apt/lists/*
COPY --from=cloner /swiftlint/ /
RUN cd SwiftLint && \
    swift build --static-swift-stdlib -Xlinker -lCFURLSessionInterface -Xlinker -lcurl --configuration release --build-path /build/.build

FROM ubuntu:${SWIFT_UBUNTU_RELEASE}
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
RUN apt-get update && apt-get install -y \
    libcurl4 \
    libxml2 \
    && rm -r /var/lib/apt/lists/*
COPY --from=builder /usr/lib/libsourcekitdInProc.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libBlocksRuntime.so /usr/lib
COPY --from=builder /usr/lib/swift/linux/libdispatch.so /usr/lib
COPY --from=builder /build/.build/release/swiftlint /usr/bin

CMD ["swiftlint", "lint"]
