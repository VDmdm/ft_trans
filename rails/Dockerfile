FROM ruby:2.7.2-alpine3.11

#install requariments
RUN apk update && apk upgrade
RUN apk add build-base libpq postgresql-dev tzdata

#install yarn
RUN apk add yarn

#install rails
RUN gem install rails
RUN gem install bundler
RUN gem update bundler

#setup
COPY pingpong /pingpong
WORKDIR /pingpong
RUN bundle update
RUN bundle install
RUN yarn install --check-files
RUN chmod +x start.sh

ENTRYPOINT "./start.sh"
