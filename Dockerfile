# --- Stage 1: Build Stage ---
FROM public.ecr.aws/docker/library/node:16-alpine AS build-stage

WORKDIR /app

COPY package*.json ./
RUN npm install --production=false

COPY . .
RUN npm run build

# --- Stage 2: Production Stage ---
FROM nginx:stable-alpine

# Copy the build folder
COPY --from=build-stage /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]