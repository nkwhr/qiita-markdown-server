FROM ruby:2.2.0

RUN apt-get update && \
    apt-get install -y libicu-dev cmake && \
    apt-get clean

RUN gem install foreman

RUN mkdir -p /usr/src/app
WORKDIR /usr/src/app

COPY Gemfile /usr/src/app/
COPY Gemfile.lock /usr/src/app/

RUN bundle install -j$(nproc)

COPY . /usr/src/app

# Install Emoji images into ./public/images/emoji
RUN bundle exec rake -f /usr/local/bundle/gems/gemoji*/lib/tasks/emoji.rake emoji

ENV RACK_ENV production
ENV PORT 8080

EXPOSE 8080

CMD ["foreman", "start"]
