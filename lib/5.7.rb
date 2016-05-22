module EnforceMysqlVersion
end

EnforceMysqlVersion::REQUIRED_VERSION = "5.7"

require "enforce_mysql_version/version"
require "enforce_mysql_version/railtie" if defined?(Rails)
