# Use official Node.js image
FROM node:18-alpine AS base

# Set working directory
WORKDIR /app

# Install pnpm (if needed)
RUN corepack enable && npm install -g pnpm

# Copy package.json and lock file
COPY package.json package-lock.json* ./

# Install all dependencies, including TypeScript
RUN npm ci --no-audit --no-fund

# Copy project files
COPY . .

# Set environment variables
ENV NEXT_TELEMETRY_DISABLED=1
ENV NODE_ENV=production

# Build the application
RUN npm run build

# Set up runtime image
FROM node:18-alpine AS runner

WORKDIR /app

# Copy built files
COPY --from=base /app/.next ./.next
COPY --from=base /app/public ./public

# Switch to non-root user for security
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs
USER nextjs

# Expose port
EXPOSE 3000

# Start Next.js server
CMD ["node", "node_modules/.bin/next", "start"]
