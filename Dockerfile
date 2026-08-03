# -----------------------------
# Stage 1 - Builder
# -----------------------------
FROM node:22-bookworm AS builder

WORKDIR /app

# Copy package files first (better caching)
COPY package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm install

# Copy application source
COPY . .

# Compile TypeScript
RUN npm run build

# -----------------------------
# Stage 2 - Runtime
# -----------------------------
FROM node:22-bookworm

WORKDIR /app

# Install Chromium dependencies
RUN apt-get update && apt-get install -y \
    ca-certificates \
    fonts-liberation \
    libasound2 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxshmfence1 \
    xdg-utils \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Copy package files
COPY package*.json ./

# Install only production dependencies
RUN npm install --omit=dev

# Copy compiled application
COPY --from=builder /app/dist ./dist

# Copy Puppeteer browser cache
COPY --from=builder /root/.cache/puppeteer /root/.cache/puppeteer

# Expose application port
EXPOSE 3000

# Start application
CMD ["npm", "start"]