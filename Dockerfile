FROM node:16.8.0-alpine3.14

RUN adduser node root

COPY *.js /app/
COPY package.json package-lock.json /app/
COPY bin/www /app/bin/www
COPY routes/*.js /app/routes/

RUN chmod 775 /app \
 && chmod 775 /app/routes \
 && chmod 775 /app/bin \
 && chmod 660 /app/*.js \
 && chmod 660 /app/routes/*.js \
 && chmod 660 /app/bin/www \
 && cd /app \
 && npm install \
 && chown -R node:root /app

WORKDIR /app

USER node

EXPOSE 3000

CMD ["node", "bin/www"]

