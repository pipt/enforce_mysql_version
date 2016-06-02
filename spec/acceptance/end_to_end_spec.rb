require "spec_helper"

RSpec.describe "starting a rails app" do
  PORTS = {
    "5.5" => "33055",
    "5.6" => "33056",
    "5.7" => "33057",
  }

  def in_rails_app
    Bundler.with_clean_env do
      Dir.chdir("spec/rails_app") do
        yield
      end
    end
  end

  around do |example|
    in_rails_app do
      example.run
    end
  end

  before :all do
    in_rails_app do
      PORTS.values.each do |port|
        `DB_PORT=#{port} RAILS_ENV=test ./bin/rake db:create`
      end
    end
  end

  before do
    ENV["DB_PORT"] = db_port
    ENV["REQUIRE_VERSION"] = gem_require
    ENV["RAILS_ENV"] = "test"
    unless exit_if_incorrect_mysql_version.nil?
      ENV["EXIT_IF_INCORRECT_MYSQL_VERSION"] = exit_if_incorrect_mysql_version
    end
  end

  let(:output) { `./bin/rails runner 'puts "#{success_message}"'` }
  let(:success_message) { "I successfully ran" }
  let(:process_status) {
    output
    $?
  }
  let(:error_message) {
    "App startup was prevented by the gem enforce_mysql_version. This app won't start unless the MySQL major/minor version is #{required_mysql_version}"
  }
  let(:warning_message) {
    "Your MySQL major/minor version doesn't match that specified in the Gemfile. The Gemfile specifies #{required_mysql_version}"
  }
  let(:workaround_message) {
    "To get the app running without changing your MySQL version, comment out the enforce_mysql_version gem in your Gemfile"
  }
  let(:gem_require) { "NOTHING" }
  let(:required_mysql_version) { "" }
  let(:db_port) { PORTS[running_mysql_version] }

  shared_examples "the right version of MySQL" do
    let(:mysql_version_message) { "Your MySQL version is" }

    context "EXIT_IF_INCORRECT_MYSQL_VERSION set to true" do
      let(:exit_if_incorrect_mysql_version) { "true" }

      it_behaves_like "an app that starts without warning or error messages"
    end

    context "EXIT_IF_INCORRECT_MYSQL_VERSION set to false" do
      let(:exit_if_incorrect_mysql_version) { "false" }

      it_behaves_like "an app that starts without warning or error messages"
    end

    context "EXIT_IF_INCORRECT_MYSQL_VERSION is unset" do
      let(:exit_if_incorrect_mysql_version) { nil }

      it_behaves_like "an app that starts without warning or error messages"
    end
  end

  shared_examples "an app that starts without warning or error messages" do
    it "starts the app" do
      expect(process_status).to be_success
    end

    it "doesn't print an error message" do
      expect(output).not_to include(error_message)
    end

    it "doesn't print a warning message" do
      expect(output).not_to include(warning_message)
    end

    it "prints the success message" do
      expect(output).to include(success_message)
    end

    it "doesn't print workaround instructions" do
      expect(output).not_to include(workaround_message)
    end

    it "doesn't print the running version of MySQL" do
      expect(output).not_to include(mysql_version_message)
    end
  end

  shared_examples "an app that prints the running version of MySQL" do
    let(:mysql_version_message) {
      "Your MySQL version is #{running_mysql_version}"
    }

    it "prints the running version of MySQL" do
      expect(output).to include(mysql_version_message)
    end
  end

  shared_examples "the wrong version of MySQL" do
    context "EXIT_IF_INCORRECT_MYSQL_VERSION set to true" do
      let(:exit_if_incorrect_mysql_version) { "true" }

      it_behaves_like "an app that prints the running version of MySQL"
      it_behaves_like "an app that exits"
    end

    context "EXIT_IF_INCORRECT_MYSQL_VERSION set to false" do
      let(:exit_if_incorrect_mysql_version) { "false" }

      it_behaves_like "an app that prints the running version of MySQL"
      it_behaves_like "an app that continues running"
    end

    context "EXIT_IF_INCORRECT_MYSQL_VERSION is unset" do
      let(:exit_if_incorrect_mysql_version) { nil }

      it_behaves_like "an app that prints the running version of MySQL"
      it_behaves_like "an app that continues running"
    end
  end

  shared_examples "an app that exits" do
    it "doesn't start the app" do
      expect(process_status).not_to be_success
    end

    it "prints an error message" do
      expect(output).to include(error_message)
    end

    it "prints workaround instructions" do
      expect(output).to include(workaround_message)
    end

    it "doesn't print the success message" do
      expect(output).not_to include(success_message)
    end
  end

  shared_examples "an app that continues running" do
    it "starts the app" do
      expect(process_status).to be_success
    end

    it "prints a warning message" do
      expect(output).to include(warning_message)
    end

    it "prints the success message" do
      expect(output).to include(success_message)
    end

    it "doesn't print workaround instructions" do
      expect(output).not_to include(workaround_message)
    end
  end

  PORTS.keys.each do |version|
    shared_context "running MySQL #{version}", running_version: version do
      let(:running_mysql_version) { version }
    end

    shared_context "requiring MySQL #{version}", required_version: version do
      let(:gem_require) { version }
      let(:required_mysql_version) { version }
    end
  end

  context "running MySQL 5.5", running_version: "5.5" do
    context "requiring MySQL 5.5", required_version: "5.5" do
      it_behaves_like "the right version of MySQL"
    end

    context "requiring MySQL 5.6", required_version: "5.6" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "requiring MySQL 5.7", required_version: "5.7" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "not requiring a specific version of MySQL" do
      it_behaves_like "the right version of MySQL"
    end
  end

  context "running MySQL 5.6", running_version: "5.6" do
    context "requiring MySQL 5.5", required_version: "5.5" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "requiring MySQL 5.6", required_version: "5.6" do
      it_behaves_like "the right version of MySQL"
    end

    context "requiring MySQL 5.7", required_version: "5.7" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "not requiring a specific version of MySQL" do
      it_behaves_like "the right version of MySQL"
    end
  end

  context "running MySQL 5.7", running_version: "5.7" do
    context "requiring MySQL 5.5", required_version: "5.5" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "requiring MySQL 5.6", required_version: "5.6" do
      it_behaves_like "the wrong version of MySQL"
    end

    context "requiring MySQL 5.7", required_version: "5.7" do
      it_behaves_like "the right version of MySQL"
    end

    context "not requiring a specific version of MySQL" do
      it_behaves_like "the right version of MySQL"
    end
  end
end
