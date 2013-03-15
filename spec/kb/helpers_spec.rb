require_relative '../spec_helper'

require 'kb/helpers'

describe KB::Helpers do

  include KB::Helpers

  describe ".suite_path" do

    it "Returns a Pathname" do
      suite_path.must_be_kind_of Pathname
    end

    describe "with a default root path" do

      it "Returns a base path if no suite name is given" do
        suite_path.to_s.must_equal "/opt/kb/suites"
      end

      it "Returns a suite path given a suite name" do
        suite_path("fuzzy").to_s.must_equal "/opt/kb/suites/fuzzy"
      end
    end

    describe "with a custom root path" do

      before  { ENV['_SPEC_KB_ROOT'] = ENV['KB_ROOT'] }
      after   { ENV['KB_ROOT'] = ENV.delete('_SPEC_KB_ROOT') }

      it "Returns a base path if no suite name is given" do
        ENV['KB_ROOT'] = "/path/to/kb"
        suite_path.to_s.must_equal "/path/to/kb/suites"
      end

      it "Returns a suite path given a suite name" do
        ENV['KB_ROOT'] = "/path/to/kb"
        suite_path("fuzzy").to_s.must_equal "/path/to/kb/suites/fuzzy"
      end
    end
  end
end
