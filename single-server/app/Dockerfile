FROM node:8.9.0

WORKDIR /app

COPY . .

RUN npm install -g http-server

ENTRYPOINT [ "http-server", "dist" ]