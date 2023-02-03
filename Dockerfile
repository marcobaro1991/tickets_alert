FROM elixir:1.14.2

RUN useradd -ms /bin/bash app

WORKDIR /code

COPY entrypoint /code/entrypoint

RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -s -- && \
    apt-get update && \
    apt-get install -y --no-install-recommends nodejs && \
    apt-get install -y inotify-tools && \
    apt-get clean && \
    npm install -g graphql-json-to-sdl@^0.3


RUN chown -R app:app /code

USER app

EXPOSE 4000

ENTRYPOINT ["./entrypoint"]
