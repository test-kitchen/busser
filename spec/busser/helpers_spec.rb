require_relative '../spec_helper'

require 'busser/helpers'

describe Busser::Helpers do

  include Busser::Helpers

  describe ".suite_path" do

    it "returns a Pathname" do
      suite_path.must_be_kind_of Pathname
    end

    describe "with a default root path" do

      it "returns a base path if no suite name is given" do
        suite_path.to_s.must_match %r{/opt/busser/suites$}
      end

      it "returns a suite path given a suite name" do
        suite_path("fuzzy").to_s.must_match %r{/opt/busser/suites/fuzzy$}
      end
    end

    describe "with a custom root path" do

      before  { ENV['_SPEC_BUSSER_ROOT'] = ENV['BUSSER_ROOT'] }
      after   { ENV['BUSSER_ROOT'] = ENV.delete('_SPEC_BUSSER_ROOT') }

      it "returns a base path if no suite name is given" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        suite_path.to_s.must_match %r{/path/to/busser/suites$}
      end

      it "returns a suite path given a suite name" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        suite_path("fuzzy").to_s.must_match %r{/path/to/busser/suites/fuzzy$}
      end
    end
  end

  describe ".vendor_path" do

    it "returns a Pathname" do
      vendor_path.must_be_kind_of Pathname
    end

    describe "with a default root path" do

      it "returns a base path if no product name is given" do
        vendor_path.to_s.must_match %r{/opt/busser/vendor$}
      end

      it "returns a vendor path given a product name" do
        vendor_path("supreme").to_s.must_match %r{/opt/busser/vendor/supreme$}
      end
    end

    describe "with a custom root path" do

      before  { ENV['_SPEC_BUSSER_ROOT'] = ENV['BUSSER_ROOT'] }
      after   { ENV['BUSSER_ROOT'] = ENV.delete('_SPEC_BUSSER_ROOT') }

      it "returns a base path if no product name is given" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        vendor_path.to_s.must_match %r{/path/to/busser/vendor$}
      end

      it "returns a suite path given a product name" do
        ENV['BUSSER_ROOT'] = "/path/to/busser"
        vendor_path("maximal").to_s.must_match \
          %r{/path/to/busser/vendor/maximal$}
      end
    end
  end
end
