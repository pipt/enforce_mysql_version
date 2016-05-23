module EnforceMysqlVersion
  class Railtie < Rails::Railtie
    initializer "enforce_mysql_version" do
      mysql_version = ActiveRecord::Base.connection.select_value("select version()")

      unless mysql_version.start_with?(EnforceMysqlVersion::REQUIRED_VERSION)
        puts "App startup was prevented by the gem enforce_mysql_version. This app won't start unless the MySQL major/minor version is #{EnforceMysqlVersion::REQUIRED_VERSION}"
        exit(false)
      end
    end
  end
end
