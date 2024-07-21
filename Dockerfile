# Stage 1: Build React-Vite app
FROM node:18-alpine AS frontend-builder

WORKDIR /app

# Copy frontend source files
COPY web/package.json web/package-lock.json ./
COPY web/ ./

# Install dependencies and build the frontend
RUN npm install && npm run build

# Stage 2: Install Gleam
FROM erlang:26 AS gleam-installer

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    xz-utils \
    gzip

# Download and install Gleam
RUN curl -L -o gleam.tar.gz https://github.com/gleam-lang/gleam/releases/download/v1.3.2/gleam-v1.3.2-x86_64-unknown-linux-musl.tar.gz \
    && tar -xzf gleam.tar.gz -C /usr/local/bin \
    && rm gleam.tar.gz

# Stage 3: Compile Gleam (Erlang) webserver
FROM erlang:26 AS backend-builder

# Copy the installed Gleam binary from the previous stage
COPY --from=gleam-installer /usr/local/bin/gleam /usr/local/bin/gleam

WORKDIR /api

# Copy backend source files
COPY api/ ./

# Copy the built frontend from the previous stage
COPY --from=frontend-builder /app/dist ./dist

# Compile the Gleam webserver
RUN gleam build

# Stage 4: Final stage to run the server
FROM erlang:26

WORKDIR /api

# Copy the installed Gleam binary
COPY --from=gleam-installer /usr/local/bin/gleam /usr/local/bin/gleam

# Copy the compiled backend from the previous stage
COPY --from=backend-builder /api ./

# Run the webserver
CMD ["gleam", "run"]
