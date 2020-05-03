FROM alpine/git:latest AS cloner
ENV SWIFTLINT_REVISION="master"
WORKDIR /swiftlint
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git

FROM swift:5.2 AS builder
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
COPY --from=cloner /swiftlint/ /
RUN cd SwiftLint && \
    swift build --configuration release --static-swift-stdlib && \
    swift build --configuration release --static-swift-stdlib --show-bin-path    
RUN cd SwiftLint && \
    mv `swift build --configuration release --static-swift-stdlib --show-bin-path`/swiftlint /swiftlint

FROM swift:5.2-slim
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
COPY --from=builder /swiftlint /bin/swiftlint
COPY --from=builder /usr/lib/libsourcekitdInProc.so /usr/lib/libsourcekitdInProc.so
RUN swiftlint version
CMD ["swiftlint", "lint"]
