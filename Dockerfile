FROM node:18-alpine

LABEL maintainer="devsecops-team"
LABEL version="1.0"

WORKDIR /app

COPY package*.json ./

RUN npm ci --only=production && npm cache clean --force

COPY src/ ./src/

EXPOSE 3000

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

RUN chown -R nodejs:nodejs /app

USER nodejs

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

CMD ["npm", "start"]
