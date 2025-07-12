FROM node:22.17.0-alpine

WORKDIR /usr/app

COPY package*.json /usr/app

RUN npm install

COPY . .

EXPOSE 4000 

CMD [ "npm", "start" ] 