FROM ruby:2.3.0

RUN apt-get update
RUN apt-get install -y nodejs nginx supervisor
RUN apt-get install -y libssl-dev

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

RUN gem update --system

CMD ["bash", "-l", "-c"]

