# frozen_string_literal: true

module Storage
  class S3Storage
    attr_reader :bucket, :client

    def initialize(access_key_id:, secret_access_key:, region:, endpoint:, bucket:)
      @client = ::Aws::S3::Client.new(
        region: region,
        access_key_id: access_key_id, 
        secret_access_key: secret_access_key,
        endpoint: endpoint
      )

      @bucket = bucket
    end

    def save(filename, content)
      client.head_bucket(bucket: bucket)

      client.put_object(bucket: bucket, body: content, key: filename)
    end
  end
end
