FROM node:20.13.1-alpine3.19 as base

WORKDIR /app/src

COPY package*.json ./

#dev stage
FROM base as dev
ENV NODE_ENV=development
RUN npm install
COPY . .
CMD ["npm", "run", "dev"]


#prod stage
FROM base as prod
ENV NODE_ENV=production
RUN npm install --only=production
COPY . .
WORKDIR /app/src/src
CMD ["node", "index.js"]