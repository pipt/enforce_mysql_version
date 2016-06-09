require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task spec: [:start_mysql_servers, :bundle_install_test_rails_app, :create_test_databases]

task :bundle_install_test_rails_app do
  Bundler.with_clean_env do
    sh "bundle install --gemfile spec/rails_app/Gemfile"
  end
end

task :create_test_databases do
  Bundler.with_clean_env do
    Dir.chdir("spec/rails_app") do
      [33055, 33056, 33057].each do |port|
        sh "DB_PORT=#{port} RAILS_ENV=test ./bin/rake db:create"
      end
    end
  end
end

task :start_mysql_servers do
  sh "docker-compose up -d"
  sleep 10
  sh "while ! nc -w 1 127.0.0.1 33055 2>/dev/null; do sleep 1; done"
  sh "while ! nc -w 1 127.0.0.1 33056 2>/dev/null; do sleep 1; done"
  sh "while ! nc -w 1 127.0.0.1 33057 2>/dev/null; do sleep 1; done"
end
