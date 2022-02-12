class AcmeTokenSaver
  def initialize
    @storage =
      if Config.settings['token_storage'] == 's3'
        Storage::S3Storage.new(
          access_key_id: Config.settings['s3']['access_key_id'],
          secret_access_key: Config.settings['s3']['secret_access_key'],
          endpoint: Config.settings['s3']['endpoint'],
          region: Config.settings['s3']['region'],
          bucket: Config.settings['acme_token_bucket']
        )
      else
        Storage::FileStorage.new(Config.settings['public_path'])
      end      
  end

  def save(filename, content)
    @storage.save(filename, content)
  end
end
