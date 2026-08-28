require_relative "../../spec_helper"

require "busser/command/plugin_install"

describe Busser::Command::PluginInstall do
  let(:command) { Busser::Command::PluginInstall.new([%w{busser-dummy}]) }

  describe "#drop_ssl_verify_peer" do
    # VERIFY_PEER is a process-global constant, so anything that leaves it
    # lowered affects every later gem download in the same run. `busser plugin
    # install` takes a list of plugins, which is exactly that situation.
    it "lowers verification for the block" do
      inside = nil
      command.send(:drop_ssl_verify_peer) { inside = OpenSSL::SSL::VERIFY_PEER }

      _(inside).must_equal OpenSSL::SSL::VERIFY_NONE
    end

    it "restores verification afterwards" do
      before = OpenSSL::SSL::VERIFY_PEER
      command.send(:drop_ssl_verify_peer) { nil }

      _(OpenSSL::SSL::VERIFY_PEER).must_equal before
    end

    # The regression this guards. A postinstall raising is not exotic: it is
    # how a plugin reports that it could not install its test framework.
    it "restores verification when the block raises" do
      before = OpenSSL::SSL::VERIFY_PEER

      _(proc { command.send(:drop_ssl_verify_peer) { raise "postinstall blew up" } })
        .must_raise RuntimeError

      _(OpenSSL::SSL::VERIFY_PEER).must_equal before
    end

    it "restores verification when the block throws" do
      before = OpenSSL::SSL::VERIFY_PEER
      catch(:done) { command.send(:drop_ssl_verify_peer) { throw :done } }

      _(OpenSSL::SSL::VERIFY_PEER).must_equal before
    end
  end
end
