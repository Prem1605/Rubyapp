FROM ruby:2.5.0
RUN gem install bundler

RUN apt-get update \
    && apt-get install -y --no-install-recommends openssh-server \
    && echo "root:Docker!" | chpasswd


# Preinstall majority of gems
WORKDIR /tmp
ADD ./Gemfile Gemfile
ADD ./Gemfile.lock Gemfile.lock
RUN bundle install


ADD . /app
WORKDIR /app
RUN bundle install

COPY sshd_config /etc/ssh/
EXPOSE 2222 80

CMD ./run.sh

