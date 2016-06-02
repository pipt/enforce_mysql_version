module EnforceMysqlVersion
  class Railtie < Rails::Railtie
    initializer "enforce_mysql_version" do
      mysql_version = ActiveRecord::Base.connection.select_value("select version()")

      unless mysql_version.start_with?(EnforceMysqlVersion::REQUIRED_VERSION)
        puts "Your MySQL version is #{mysql_version}"
        if ENV["EXIT_IF_INCORRECT_MYSQL_VERSION"] == "true"
          puts "App startup was prevented by the gem enforce_mysql_version. This app won't start unless the MySQL major/minor version is #{EnforceMysqlVersion::REQUIRED_VERSION}"
          puts "To get the app running without changing your MySQL version, comment out the enforce_mysql_version gem in your Gemfile"
          exit(false)
        else
          puts "Your MySQL major/minor version doesn't match that specified in the Gemfile. The Gemfile specifies #{EnforceMysqlVersion::REQUIRED_VERSION}"
        end
      end
    end
  end
end
