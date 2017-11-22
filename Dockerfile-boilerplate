FROM node:8-alpine

RUN adduser node root

COPY package.json /app/
RUN cd /app; npm install

