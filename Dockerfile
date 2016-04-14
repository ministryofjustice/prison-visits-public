FROM ministryofjustice/ruby:2.3.0-webapp-onbuild

EXPOSE 3000

RUN RAILS_ENV=production bundle exec rake assets:precompile --trace

ENTRYPOINT ["./run.sh"]
