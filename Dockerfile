FROM node:18-alpine

LABEL maintainer="devsecops-team"
LABEL version="1.0"

WORKDIR /app

# Copier package.json et package-lock.json
COPY package*.json ./

# Installer les dépendances production
RUN npm install --only=production && npm cache clean --force

# Copier le code source
COPY src/ ./src/

EXPOSE 3000

# Créer l'utilisateur nodejs
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001

# Changer le propriétaire du dossier
RUN chown -R nodejs:nodejs /app

# Utiliser nodejs
USER nodejs

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Commande par défaut
CMD ["npm", "start"]
