require_relative '../spec_helper'

require 'busser/helpers'

describe Busser::Helpers do

  include Busser::Helpers

  describe ".suite_path" do

    it "Returns a Pathname" do
      suite_path.must_be_kind_of Pathname
    end

    describe "with a default root path" do

      it "Returns a base path if no suite name is given" do
        suite_path.to_s.must_equal "/opt/busser/suites"
      end

      it "Returns a suite path given a suite name" do
        suite_path("fuzzy").to_s.must_equal "/opt/busser/suites/fuzzy"
      end
    end

    describe "with a custom root path" do

      before  { ENV['_SPEC_BUSSER_ROOT'] = ENV['BUSSER_ROOT'] }
      after   { ENV['BUSSER_ROOT'] = ENV.delete('_SPEC_BUSSER_ROOT') }

      it "Returns a base path if no suite name is given" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        suite_path.to_s.must_equal "/path/to/busser/suites"
      end

      it "Returns a suite path given a suite name" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        suite_path("fuzzy").to_s.must_equal "/path/to/busser/suites/fuzzy"
      end
    end
  end
end
