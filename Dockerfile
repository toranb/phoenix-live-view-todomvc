FROM elixir:1.14.4-alpine

ENV MIX_ENV=prod

COPY . /example
WORKDIR /example

RUN apk update \
    && apk --no-cache --update add nodejs npm \
    && mix local.rebar --force \
    && mix local.hex --force

RUN mix deps.get
RUN mix deps.update certifi
RUN mix deps.compile

RUN cd ./assets \
    && npm install \
    && npm run deploy \
    && cd .. \
    && mix phx.digest

RUN mix do compile
CMD mix do phx.server

EXPOSE 4000
