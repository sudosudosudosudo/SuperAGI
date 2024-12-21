FROM node:18-alpine AS deps
FROM python:3.10-slim-bullseye

# Install git
RUN apt-get update && \
    apt-get install -y git

WORKDIR /app

# Use RUN to execute git commands
RUN git add package-lock.json && \
    git commit -m "Add package manager lockfile" && \
    apk add --no-cache libc6-compat
COPY package.json package-lock.json ./
RUN npm ci

# Rebuild the source code only when needed
FROM node:18-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules

COPY . .
ARG NEXT_PUBLIC_API_BASE_URL=/api
ENV NEXT_PUBLIC_API_BASE_URL=$NEXT_PUBLIC_API_BASE_URL
ARG NEXT_PUBLIC_MIXPANEL_AUTH_ID
ENV NEXT_PUBLIC_MIXPANEL_AUTH_ID=$NEXT_PUBLIC_MIXPANEL_AUTH_ID
EXPOSE 3000

CMD ["npm", "run", "dev"]
