require 'yaml'
require 'bosh_cacher/config_renderer'

module BoshCacher
  module BlobsUploader

    def initialize(release)
    end

    def upload_blobs_for(release)
      release = release
      blobstore = release.blobstore
      blobs_manager = Bosh::Cli::BlobManager.new(release)
      index = blobs_manager.instance_variable_get(:@index)

      index.eack_pair do |file, object|
        blob_path = File.join(release.dir, '.blobs', object['sha'])
        say("Uploading #{file.make_green} from #{blob_path.make_green}")
        blobstore.create(File.open(blob_path, "r"), object['object_id'])
      end
    end
  end
end
