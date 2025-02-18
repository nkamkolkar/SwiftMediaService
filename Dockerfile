# Build Stage
#FROM swift:5.8 AS builder
# Above failed with error: error: 'app': package 'app' is using Swift tools version 5.9.0 but the installed version is 5.8.1 

# Build Stage - Use Swift 5.9 to match project
FROM swift:5.9 AS builder


# Set working directory
WORKDIR /app

# Copy source files and package manager files
COPY . .

# Build the Swift executable in release mode
RUN swift build -c release 

# Deployment Stage
FROM ubuntu:22.04

# Install required Swift runtime dependencies
RUN apt-get update && apt-get install -y \
    libatomic1 \
    libicu-dev \
    libcurl4-openssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy compiled binary from builder stage
COPY --from=builder /app/.build/release/SwiftMediaService /app/SwiftMediaService

# Copy Swift runtime libraries
COPY --from=builder /usr/lib/swift /usr/lib/swift

# Expose the server port
EXPOSE 8080

# Start the service
CMD ["/app/SwiftMediaService"]

