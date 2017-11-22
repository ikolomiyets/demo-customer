FROM ikolomiyets/node-boilerplate

RUN adduser node root

COPY *.js /app/
COPY bin/www /app/bin/www
COPY routes/*.js /app/routes/

RUN chmod 775 /app
RUN chmod 775 /app/routes
RUN chmod 775 /app/bin

RUN chmod 660 /app/*.js
RUN chmod 660 /app/routes/*.js
RUN chmod 660 /app/bin/www
RUN chmod -R 775 /app/node_modules

RUN chown -R node:root /app

WORKDIR /app

USER node

CMD ["node", "bin/www"]

