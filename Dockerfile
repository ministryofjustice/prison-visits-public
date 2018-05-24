FROM ministryofjustice/ruby:2.5.1-webapp-onbuild

EXPOSE 3000

RUN RAILS_ENV=production STAFF_SERVICE_URL=http://example.com SERVICE_URL=http://example.com bin/rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
