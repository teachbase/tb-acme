# frozen_string_literal: true

require './boot'
require "cuba"
require "cuba/safe"
require 'acme-client'
require 'pry-byebug'
require 'json'
require 'openssl'

Boot.load

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

          CertService.new.handle(data)
          res.write "ok"
        end
      end
    end
  end
end
