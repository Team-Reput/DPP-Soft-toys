# Build Stage
FROM ghcr.io/cirruslabs/flutter:3.38.9 AS build

WORKDIR /app
COPY . .

RUN flutter clean
RUN flutter pub get
RUN flutter build web --pwa-strategy=none

# Serve Stage
FROM nginx:alpine

RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom NGINX configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]