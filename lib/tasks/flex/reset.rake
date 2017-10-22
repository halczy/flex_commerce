namespace :flex do
  desc 'Reset all databases and setup geos and seeds application'
  task reset: %w[ db:drop db:create db:migrate flex:demo ]
end
