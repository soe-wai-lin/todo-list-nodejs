# FROM node:22.17.0-alpine

FROM node:18.20-alpine3.20

WORKDIR /usr/app

COPY package*.json /usr/app

RUN npm install

COPY . .

EXPOSE 4000 

CMD [ "npm", "start" ] 