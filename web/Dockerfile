# syntax=docker/dockerfile:1.7

FROM node:24-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

FROM base AS deps
WORKDIR /app

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY web/package.json web/package.json
COPY packages/version-info/package.json packages/version-info/package.json

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --frozen-lockfile --filter @imput/cobalt-web...

FROM deps AS build

COPY web web
COPY packages/version-info packages/version-info

ARG WEB_DEFAULT_API
ARG WEB_HOST
ARG WEB_PLAUSIBLE_HOST
ARG ENABLE_DEPRECATED_YOUTUBE_HLS=false

ENV WEB_DEFAULT_API=$WEB_DEFAULT_API
ENV WEB_HOST=$WEB_HOST
ENV WEB_PLAUSIBLE_HOST=$WEB_PLAUSIBLE_HOST
ENV ENABLE_DEPRECATED_YOUTUBE_HLS=$ENABLE_DEPRECATED_YOUTUBE_HLS

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm --filter @imput/cobalt-web build

FROM nginx:1.27-alpine AS runtime
COPY web/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/web/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
