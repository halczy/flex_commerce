namespace :geo do
  desc 'Download and import Chinese geographic data'
  task :setup => %w[ geo:fetch geo:import ]
end
