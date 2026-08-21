FROM alpine:3.19
ARG UID=1000
ARG GID=1000
ARG OPENCODE_VERSION=latest
ARG GH_VERSION=2.98.0
RUN apk add --no-cache curl ca-certificates bash libstdc++ libgcc git \
    && if [ "$OPENCODE_VERSION" = "latest" ]; then \
         curl -fsSL https://opencode.ai/install | bash; \
       else \
         curl -fsSL https://opencode.ai/install | bash -s -- --version "$OPENCODE_VERSION"; \
       fi \
    && ls -R /root/ \
    && mv /root/.opencode/bin/opencode /usr/local/bin/opencode || echo "File not found!" \
    && ARCH=$(case "$(uname -m)" in \
         x86_64) echo amd64 ;; \
         aarch64) echo arm64 ;; \
         *) echo "unsupported arch: $(uname -m)" && exit 1 ;; \
       esac) \
    && curl -fsSL -o /tmp/gh_${GH_VERSION}_linux_${ARCH}.tar.gz "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${ARCH}.tar.gz" \
    && curl -fsSL -o /tmp/gh_${GH_VERSION}_checksums.txt "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_checksums.txt" \
    && grep " gh_${GH_VERSION}_linux_${ARCH}.tar.gz" /tmp/gh_${GH_VERSION}_checksums.txt | (cd /tmp && sha256sum -c -) \
    && tar -xzf /tmp/gh_${GH_VERSION}_linux_${ARCH}.tar.gz -C /tmp \
    && mv /tmp/gh_${GH_VERSION}_linux_${ARCH}/bin/gh /usr/local/bin/gh \
    && rm -rf /tmp/gh_${GH_VERSION}_linux_${ARCH}.tar.gz /tmp/gh_${GH_VERSION}_checksums.txt /tmp/gh_${GH_VERSION}_linux_${ARCH} \
    && gh --version
RUN addgroup -g $GID coder 2>/dev/null; \
	GROUP_NAME=$(getent group $GID | cut -d: -f1); \
	adduser -D -s /bin/sh -u $UID -G "$GROUP_NAME" coder \
    && mkdir -p /home/coder/.config/opencode \
    && mkdir -p /home/coder/.local/share/opencode /home/coder/.cache/opencode /home/coder/.local/state/opencode \
    && chown -R coder:"$GROUP_NAME" /home/coder
USER coder
WORKDIR /workspace
CMD ["opencode"]
