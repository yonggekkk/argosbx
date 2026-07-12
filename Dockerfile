# syntax=docker/dockerfile:1.7
FROM node:22-alpine AS deps
WORKDIR /app
COPY container/nodejs/package.json container/nodejs/package-lock.json ./
RUN npm ci --omit=dev

FROM node:22-alpine AS runtime
ARG ARGOSBX_ASSET_REPO=yonggekkk/argosbx
RUN apk add --no-cache bash ca-certificates coreutils curl iproute2 openssl shadow tzdata wget
ENV NODE_ENV=production \
    HOME=/home/node \
    ARGOSBX_ASSET_REPO=${ARGOSBX_ASSET_REPO}
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node container/nodejs/package.json container/nodejs/package-lock.json container/nodejs/index.js container/nodejs/start.sh container/nodejs/mieru.sh ./
RUN chmod 0755 /app/start.sh && mkdir -p /home/node/agsbx && chown -R node:node /home/node /app
USER node
CMD ["node", "index.js"]