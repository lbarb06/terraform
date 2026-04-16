FROM node:20-alpine

WORKDIR /app

ARG GIT_SHA=dev
ENV APP_VERSION=$GIT_SHA

COPY package*.json ./
RUN npm install --omit=dev

COPY src ./src

EXPOSE 3000

CMD ["npm", "start"]
