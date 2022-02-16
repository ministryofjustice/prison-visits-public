FROM ruby:2.6.7-stretch

EXPOSE 3000
RUN gem update bundler --no-doc
RUN RAILS_ENV=production STAFF_SERVICE_URL=http://example.com SERVICE_URL=http://example.com bin/rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
