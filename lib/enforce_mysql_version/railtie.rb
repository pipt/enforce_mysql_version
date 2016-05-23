module EnforceMysqlVersion
  class Railtie < Rails::Railtie
    initializer "enforce_mysql_version" do
      mysql_version = ActiveRecord::Base.connection.execute("select version()").first.first

      unless mysql_version =~ /^#{EnforceMysqlVersion::REQUIRED_VERSION}/
        puts "App startup was prevented by the gem enforce_mysql_version. This app won't start unless the MySQL major/minor version is #{EnforceMysqlVersion::REQUIRED_VERSION}"
        exit(false)
      end
    end
  end
end
