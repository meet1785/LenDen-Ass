FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

RUN addgroup -g 1001 appgroup && adduser -u 1001 -G appgroup -s /bin/sh -D appuser
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=3s CMD wget -q --spider http://localhost:5000/health || exit 1

CMD ["node", "server.js"]
