# frozen_string_literal: true

module Storage
  class FileStorage
    def initialize(path)
      @path = path
    end

    def save(filename, content)
      dir = File.join(@path, File.dirname(filename))
      FileUtils.mkdir_p(dir) unless Dir.exists?(dir)

      File.write(
        File.join(@path, filename),
        content
      )
    end
  end
end
