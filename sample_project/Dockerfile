FROM localhost:5000/base-image

ENV APP_HOME /webapp
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install --without test development

ADD . $APP_HOME
RUN bundle exec rake assets:precompile

COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 80
CMD ["/usr/bin/supervisord"]

