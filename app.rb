# frozen_string_literal: true

Cuba.define do
  on 'api' do
    on 'v1' do
      on post do
        on 'register' do
          data = if req.env["CONTENT_TYPE"] == 'application/json'
                  JSON.parse req.body.read
                else
                  {}
                end

          $logger.info("[ INCOME REQUEST, #{Time.now} ], #{data}")

          CertService.new.perform(data)
          res.write "ok"
        end
      end
    end
  end
end
