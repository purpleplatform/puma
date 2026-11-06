# frozen_string_literal: true

require_relative "helper"
require_relative "helpers/integration"

require "puma/plugin"
require "puma/configuration"
require "puma/launcher"

class TestPluginSystemdJruby < TestIntegration

  THREAD_LOG = TRUFFLE ? "{ 0/16 threads, 16 available, 0 backlog }" :
    "{ 0/5 threads, 5 available, 0 backlog }"

  def setup
    skip_unless :linux
    skip_unless :unix
    skip_unless_signal_exist? :TERM
    skip_unless :jruby

    super

    ENV["NOTIFY_SOCKET"] = "/tmp/doesntmatter"
  end

  def teardown
    return if skipped?
    ENV.delete "NOTIFY_SOCKET"
    super
  end

  # Launcher#initialize adds the systemd plugin when NOTIFY_SOCKET is set,
  # except on JRuby. Check the launcher's own plugin loader: the global
  # Puma::Plugins registry also holds plugins that other tests in this process
  # loaded (TestCLI#test_plugins loads systemd), so it depends on test order.
  def test_systemd_plugin_not_loaded
    launcher = Puma::Launcher.new Puma::Configuration.new, log_writer: Puma::LogWriter.strings

    assert_empty launcher.config.plugins.instance_variable_get(:@instances)
  end
end
