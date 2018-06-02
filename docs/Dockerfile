FROM node:9.11.1-alpine

# utils
RUN apk update \
    && apk add --no-cache git curl \
    && rm -rf /var/cache/apk/*

# goss testing
RUN curl -fsSL https://goss.rocks/install | sh \
    && goss --version

ARG VUEPRESS_VERSION=latest

# vue press install
# https://vuepress.vuejs.org/
RUN npm install -g vuepress@${VUEPRESS_VERSION}

# fixin up temporaty prettier issue
# Module build failed: Error: No parser and no file path given, couldn't infer a parser.
# https://stackoverflow.com/questions/50555953/vue-webpack-template-missing-parser
RUN cd /usr/local/lib/node_modules/vuepress \
    && npm i prettier@~1.12.0

# viepress validation
RUN  mkdir -p /tmp/vuepress-app \
    && cd /tmp/vuepress-app \
    && echo '# Hello VuePress' > README.md \
    && vuepress --version \
    && vuepress build 
