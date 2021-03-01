FROM node:alpine AS base
RUN apk add --no-cache \
    build-base \
    cairo-dev \
    cairo \
    cairo-tools \
    curl \
    git \
    python \
    make \
    build-base \
    g++ \
    jpeg-dev \
    pango-dev \
    giflib-dev

WORKDIR /app

FROM base AS builder
COPY package.json yarn.lock ./
COPY . .
RUN rm -rf node_modules

RUN yarn install --production && \
    cp -R node_modules /tmp/node_modules && \
    yarn install && \
    yarn build

FROM base AS release
COPY --from=builder /tmp/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
EXPOSE 3099
ENTRYPOINT [ "node", "dist/index.js" ]
