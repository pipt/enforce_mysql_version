require "enforce_mysql_version"

EnforceMysqlVersion::REQUIRED_VERSION = "5.6"

require "enforce_mysql_version/railtie" if defined?(Rails)
