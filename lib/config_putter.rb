class ConfigPutter
  attr_reader :capistrano

  # capistrano - the Capistrano::Configuration object
  def initialize(capistrano)
    @capistrano = capistrano
  end

  # Put all files
  #
  # local_source_path - all files in this local directory are uploaded. ERB
  # files are evaluated and uploaded without the .erb extension.
  #
  # remote_destination_path - where the files are uploaded to
  def put_all(local_source_path, remote_destination_path)
    Dir.glob(File.join(local_source_path, "*")).each do |filepath|
      klass = is_erb?(filepath) ? ErbPutter : FilePutter
      klass.new(capistrano, filepath, remote_destination_path).put
    end
  end

  def is_erb?(filepath)
    filepath[-4..-1] == '.erb'
  end

  class FilePutter
    attr_accessor :cap, filepath, remote_path

    def initialize(cap, filepath, remote_path)
      @cap = cap
      @filepath = filepath
      @remote_path = remote_path
    end

    def put
      cap.put(read_file, destination)
    end

    def read_file
      File.read(filepath)
    end

    def remote_filename
      File.basename(filepath)
    end

    def destination
      File.join(remote_path, remote_filename)
    end
  end

  class ErbPutter < FilePutter
    def read_file
      ERB.new(super).result(binding)
    end

    def remote_filename
      without_erb_extension(super)
    end

  private

    def without_erb_extension(filename)
      filename[0..-5]
    end
  end
end
