require 'bosh_syncer/release_manager'
require 'bosh_syncer/config_manager'

module Bosh::Cli::Command
  class Syncer < Bosh::Cli::Command::Base
    include BoshSyncer::ConfigManager
    include BoshSyncer::ReleaseManager
    include BoshSyncer::Helpers

    usage 'cache'
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
    def cache_blobs(*args)

      unless options[:config]
        say "You need to specify config file with --cache option.".make_red
        exit 1
      end

      
      release_manager.fetch(options[:release] || default_release) do |release_folder|
        set_folder(release_folder)

        blob_manager.sync
        blob_manager.print_status
        
        config_manager.setup(options[:config]) do
          update_config
          blob_manager.blobs_to_upload.each do |blob|
            say "Uploading blob #{blob.make_yellow}? to your blobstore."
            blob_manager.upload_blob(blob)
          end
        end
      end
    end

    private

    def default_release
      "https://github.com/cloudfoundry/cf-release.git"
    end

  end
end