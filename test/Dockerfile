ARG BASE_IMAGE=alpine:3.18
FROM ${BASE_IMAGE}

# Install nano and dependencies based on distro
RUN if command -v apk > /dev/null 2>&1; then \
        apk add --no-cache nano nano-syntax coreutils; \
    elif command -v apt-get > /dev/null 2>&1; then \
        apt-get update -qq && apt-get install -qq -y nano && rm -rf /var/lib/apt/lists/*; \
    fi

# Create backup directory
RUN mkdir -p /root/.nano/backups

# Create test files
RUN echo 'function hello() { return "world"; }' > /tmp/test.js && \
    echo '#!/bin/bash\necho "hello"' > /tmp/test.sh && \
    echo 'int main() { return 0; }' > /tmp/test.c && \
    echo '# Heading\n\nSome **bold** text.' > /tmp/test.md

# Copy test script
COPY validate.sh /usr/local/bin/validate.sh
RUN chmod +x /usr/local/bin/validate.sh

ENTRYPOINT ["/usr/local/bin/validate.sh"]
