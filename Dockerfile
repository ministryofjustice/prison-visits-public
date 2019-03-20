FROM registry.service.dsd.io/ruby:2.6.2-webapp-onbuild

EXPOSE 3000
RUN gem update bundler --no-doc
RUN RAILS_ENV=production STAFF_SERVICE_URL=http://example.com SERVICE_URL=http://example.com rails assets:precompile --trace

ENTRYPOINT ["./run.sh"]
