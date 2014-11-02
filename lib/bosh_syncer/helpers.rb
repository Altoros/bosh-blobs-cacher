module BoshSyncer
  module Helpers

    def set_folder(folder)
      Dir.chdir(folder)
      @work_dir = folder
      update_config!
    end

    def update_config!
      @release = nil
    end

  end
end
