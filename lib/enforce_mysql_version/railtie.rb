module EnforceMysqlVersion
  class Railtie < Rails::Railtie
    initializer "enforce_mysql_version" do
      mysql_version = ActiveRecord::Base.connection.execute("select version()").first.first

      unless mysql_version =~ /^#{EnforceMysqlVersion::VERSION}/
        puts "This app won't start unless the MySQL major/minor version is #{EnforceMysqlVersion::VERSION}"
        exit(false)
      end
    end
  end
end
