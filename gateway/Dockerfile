FROM node:20-alpine
ENV NODE_ENV=production
ENV BACKEND_SERVICE_URL=http://backend:3847
ENV PORT=5921
WORKDIR /app
COPY package*.json ./
RUN npm install --only=production
COPY . .
USER node
EXPOSE 5921
CMD ["node", "src/gateway.js"]