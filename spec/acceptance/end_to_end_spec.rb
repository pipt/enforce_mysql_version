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
  let(:gem_require) { required_mysql_version }
  let(:required_mysql_version) { "" }

  shared_examples "the right version of MySQL" do |running_version|
    context "when MySQL is version #{running_version}" do
      let(:db_port) { PORTS[running_version] }

      it "starts the app" do
        expect(process_status).to be_success
      end

      it "doesn't print an error message" do
        expect(output).not_to include(error_message)
      end

      it "prints the success message" do
        expect(output).to include(success_message)
      end
    end
  end

  shared_examples "the wrong version of MySQL" do |running_version|
    context "when MySQL is version #{running_version}" do
      let(:db_port) { PORTS[running_version] }
      let(:mysql_version_message) {
        "Your MySQL version is #{running_version}"
      }
      let(:workaround_message) {
        "To get the app running without changing your MySQL version, comment out the enforce_mysql_version gem in your Gemfile"
      }

      it "doesn't start the app" do
        expect(process_status).not_to be_success
      end

      it "prints an error message" do
        expect(output).to include(error_message)
      end

      it "prints the running version of MySQL" do
        expect(output).to include(mysql_version_message)
      end

      it "prints workaround instructions" do
        expect(output).to include(workaround_message)
      end

      it "doesn't print the success message" do
        expect(output).not_to include(success_message)
      end
    end
  end

  describe "requiring MySQL 5.5" do
    let(:required_mysql_version) { "5.5" }

    it_behaves_like "the right version of MySQL", "5.5"
    it_behaves_like "the wrong version of MySQL", "5.6"
    it_behaves_like "the wrong version of MySQL", "5.7"
  end

  describe "requiring MySQL 5.6" do
    let(:required_mysql_version) { "5.6" }

    it_behaves_like "the wrong version of MySQL", "5.5"
    it_behaves_like "the right version of MySQL", "5.6"
    it_behaves_like "the wrong version of MySQL", "5.7"
  end

  describe "requiring MySQL 5.7" do
    let(:required_mysql_version) { "5.7" }

    it_behaves_like "the wrong version of MySQL", "5.5"
    it_behaves_like "the wrong version of MySQL", "5.6"
    it_behaves_like "the right version of MySQL", "5.7"
  end

  describe "not requiring a specific version of MySQL" do
    let(:gem_require) { "NOTHING" }

    it_behaves_like "the right version of MySQL", "5.5"
    it_behaves_like "the right version of MySQL", "5.6"
    it_behaves_like "the right version of MySQL", "5.7"
  end
end
