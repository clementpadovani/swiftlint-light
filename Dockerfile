FROM swift:5.2 as builder
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
ENV SWIFTLINT_REVISION="master"
RUN git clone --branch $SWIFTLINT_REVISION https://github.com/realm/SwiftLint.git
WORKDIR SwiftLint
RUN swift build --configuration release --static-swift-stdlib && \
    cp ./.build/release/swiftlint /swiftlint

FROM scratch
LABEL maintainer "Clement Padovani <clement.padovani@gmail.com>"
COPY --from=builder swiftlint /usr/local/bin/swiftlint
CMD ["swiftlint", "lint"]
