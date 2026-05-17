FROM node:18-alpine AS build

WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm ci --silent

# Copy source and build
COPY . .
RUN npm run build

FROM nginx:stable-alpine

# Copy built assets
COPY --from=build /app/dist /usr/share/nginx/html

# Custom nginx config to support SPA routing and API proxying
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
