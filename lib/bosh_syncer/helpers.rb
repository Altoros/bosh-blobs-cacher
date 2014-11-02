module BoshSyncer
  module Helpers

    def set_folder(folder)
      @work_dir = folder
      Dir.chdir(folder)
      update_config!
    end

    def update_config!
      
      @release = nil
    end

  end
end
