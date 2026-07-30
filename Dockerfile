# Stage 1: Build the Flutter web app
FROM ubuntu:latest AS builder

# Prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Install Flutter dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Clone the Flutter stable channel repository (shallow clone for faster builds)
RUN git clone --depth 1 --branch 3.41.7 https://github.com/flutter/flutter.git /usr/local/flutter

# Add flutter to path
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Run basic check and disable analytics
RUN flutter doctor -v
RUN flutter config --no-analytics

WORKDIR /app

# Copy dependency specifications first to leverage Docker layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application source code
COPY . .

# Build the Flutter web app in release mode
RUN flutter build web --release

# Stage 2: Serve the app with Nginx
FROM nginx:alpine

# Remove the default Nginx index page
RUN rm -rf /usr/share/nginx/html/*

# Copy build output from the builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom Nginx configuration template for client-side routing fallback
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

# Restrict envsubst to only substitute $PORT (leaving Nginx variables like $uri intact)
ENV NGINX_ENVSUBST_FILTER="PORT"

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
