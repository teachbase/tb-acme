# frozen_string_literal: true

every 1.day, at: '11:55pm' do
  rake "cert:refresh"
end
