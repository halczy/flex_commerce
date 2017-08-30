namespace :geo do
  desc 'Download and import Chinese geographic data'
  task :run => %w[ geo:download geo:import ]
end
