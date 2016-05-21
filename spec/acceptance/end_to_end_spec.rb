require "spec_helper"

RSpec.describe "starting a rails app" do
  around do |example|
    Bundler.with_clean_env do
      Dir.chdir("spec/rails_app") do
        example.run
      end
    end
  end

  before do
    ENV["DB_PORT"] = db_port
    ENV["RAILS_ENV"] = "test"
    `./bin/rake db:create`
  end

  let(:output) { `./bin/rails runner 'exit'` }
  let(:process_status) {
    output
    $?
  }
  let(:error_message) {
    "This app won't start unless the MySQL major/minor version is #{EnforceMysqlVersion::VERSION}"
  }

  context "when MySQL is the right version" do
    let(:db_port) { "3306" }

    it "starts the app" do
      expect(process_status).to be_success
    end

    it "doesn't print an error message" do
      expect(output).not_to include(error_message)
    end
  end

  context "when MySQL is the wrong version" do
    let(:db_port) { "3307" }

    it "doesn't start the app" do
      expect(process_status).not_to be_success
    end

    it "prints an error message" do
      expect(output).to include(error_message)
    end
  end
end
