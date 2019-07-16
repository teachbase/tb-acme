job_type :rake, "cd :path && :environment_variable=:environment bundle exec rake :task"

every 1.day, at: '11:55pm' do
  rake "cert:refresh"
end

every 7.days, at: '11:30' do
  rake 'quota:reset'
end
