# ---- Build Stage ----
  FROM node:18-alpine AS build
  RUN apk add --no-cache libc6-compat
  WORKDIR /app
  
  COPY package*.json ./
  RUN npm ci --legacy-peer-deps
  COPY . .
  RUN npm run build
  
  # ---- Runtime Stage ----
  FROM node:18-alpine
  RUN apk add --no-cache dumb-init && adduser -D nextuser
  WORKDIR /app
  
  COPY --from=build --chown=nextuser:nextuser /app/public ./public
  COPY --from=build --chown=nextuser:nextuser /app/.next/standalone ./
  COPY --from=build --chown=nextuser:nextuser /app/.next/static ./.next/static
  
  USER nextuser
  EXPOSE 3000
  
  ENV HOST=0.0.0.0 PORT=3000
  CMD ["dumb-init", "node", "server.js"]
  