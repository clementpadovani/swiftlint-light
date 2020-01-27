FROM swift:5.1 as builder
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
ENV SWIFTLINT_REVISION="master"
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git && \
    cd SwiftLint && \
    swift build --configuration release --static-swift-stdlib && \
    mv `swift build --configuration release --static-swift-stdlib --show-bin-path`/swiftlint /usr/bin && \
    cd .. && \
    rm -rf SwiftLint && \
    cp /usr/bin/swiftlint /swiftlint

FROM swift:5.1-slim
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
COPY --from=builder swiftlint .
CMD ["swiftlint", "lint"]