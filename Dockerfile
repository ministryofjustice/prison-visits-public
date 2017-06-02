FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

EXPOSE 3000
RUN gem update bundler --no-doc
RUN RAILS_ENV=production STAFF_SERVICE_URL=foo bin/rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
