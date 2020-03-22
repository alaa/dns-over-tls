FROM ruby:2.6.3

RUN apt update && apt upgrade -y && apt install -y knot-dnsutils
RUN mkdir /src
WORKDIR /src
ADD . .
RUN bundle install
EXPOSE 53
ENTRYPOINT ["ruby", "/src/dns-over-tls.rb"]
