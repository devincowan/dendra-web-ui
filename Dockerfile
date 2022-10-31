FROM node:16.17 AS base
MAINTAINER J. Scott Smith <scott@newleafsolutionsinc.com>
# Following Best Practices and guidelines at:
#   https://nodejs.org/en/docs/guides/nodejs-docker-webapp/
#   https://github.com/nodejs/docker-node/blob/master/docs/BestPractices.md
RUN groupmod -g 2000 node \
  && usermod -u 2000 -g 2000 node
WORKDIR /home/node/app
# Install dependencies
COPY package.json /home/node/app
COPY package-lock.json /home/node/app
# Best practice: run with NODE_ENV set to production
ENV NODE_ENV production
RUN npm install

# Linting layer, won't make it into production
FROM base AS linter
ENV NODE_ENV development
RUN npm install
COPY . /home/node/app
COPY .gitignore /home/node/app
RUN npm run lint

#
# Test stage skipped, since external testing is done
#

# Builder layer
FROM linter AS builder
RUN npm run generate
RUN date > .buildtime

# Production layer
FROM caddy:2.6.2-alpine as prod

# Install envsubst command for replacing __env files
RUN set -x \
  && apk add gettext libintl

COPY docker-entrypoint.sh /usr/local/bin/

# Copy config
COPY caddy.docker.json /etc/caddy/caddy.json

# Copy source dist
COPY --from=builder /home/node/app/.buildtime .buildtime
COPY --from=builder dist /srv

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["caddy", "run", "--config", "/etc/caddy/caddy.json"]
