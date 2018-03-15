FROM node:8.9.0

WORKDIR /app

COPY . .

RUN npm install -g yarn
RUN npm install -g http-server
RUN yarn
RUN yarn build

ENTRYPOINT [ "http-server", "dist" ]