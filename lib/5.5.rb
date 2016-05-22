require "enforce_mysql_version"

EnforceMysqlVersion::REQUIRED_VERSION = "5.5"

require "enforce_mysql_version/railtie" if defined?(Rails)
