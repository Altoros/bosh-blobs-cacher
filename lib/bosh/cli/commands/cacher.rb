$LOAD_PATH.unshift(File.expand_path('../../../..', __FILE__))

require 'bosh_cacher/release_manager'
require 'bosh_cacher/config_manager'
require 'bosh_cacher/config_renderer'
require 'bosh_cacher/blobs_uploader'
require 'bosh_cacher/helpers'

module Bosh::Cli::Command
  class Cacher < Bosh::Cli::Command::Base
    include BoshCacher::ConfigManager
    include BoshCacher::ReleaseManager
    include BoshCacher::Helpers

    usage 'cacher'
    desc 'show bosh cache sub-commands'
    def help
      say "bosh cache sub-commands:\n"
      commands = Bosh::Cli::Config.commands.values.find_all { |command| command.usage =~ /^cache/ }
      Bosh::Cli::Command::Help.list_commands(commands)
    end

    usage 'cache blobs'
    desc 'upload blobs from specific release and store them in your blobstorage.'
    option '--release release', String, 'BOSH release that you want to cache (folder or github repo). ' + 
                                        'By default is set cf-release github repo.'
    option '--config config_file', String,  'Config file to access your blob storage.'
    def cache_blobs

      unless options[:config]
        say "You need to specify config file with --cache option.".make_red
        exit 1
      end

      
      release_manager.fetch(options[:release] || default_release) do |release_folder|
        set_folder(release_folder)

        blob_manager.sync
        blob_manager.print_status

        config_manager.setup(options) do
          update_config!
          BoshCacher::BlobsUploader.new(release).upload_blobs
        end
      end
    end

    usage 'cacher generate config'
    desc 'upload blobs from specific release and store them in your blobstorage.'
    option '--provider provider', String, '.'
    def generate_example_config(path = Dir.pwd)
      path = File.join(path, 'config.yml') if File.directory?(path)
      config_renderer = BoshCacher::ConfigRenderer.new(options.merge!(validate: false))
      config_renderer.render_example_config(path)
      say "Example config is generated to #{path}."
    end

    private

    def default_release
      'https://github.com/cloudfoundry/cf-release.git'
    end

  end
end