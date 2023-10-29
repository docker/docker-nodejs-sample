# syntax=docker/dockerfile:1

# Comments are provided throughout this file to help you get started.
# If you need more help, visit the Dockerfile reference guide at
# https://docs.docker.com/engine/reference/builder/

ARG NODE_VERSION=18.12.0

FROM node:${NODE_VERSION}-alpine as base
WORKDIR /usr/src/app
# Expose the port that the application listens on.
EXPOSE 3000
FROM base as dev
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --include=dev
# Run the application as a non-root user.
USER node
# Copy the rest of the source files into the image.
COPY . .
CMD npm run dev

FROM base as prod
# Use production node environment by default.
ENV NODE_ENV production

# Leverage a bind mounts to package.json and package-lock.json to avoid having to copy them into into this layer.
RUN --mount=type=bind,source=package.json,target=package.json \
    --mount=type=bind,source=package-lock.json,target=package-lock.json \
    --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

USER node
COPY . .
# Run the application.
CMD node src/index.js
