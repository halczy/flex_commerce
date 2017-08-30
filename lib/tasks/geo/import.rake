namespace :geo do
  desc 'Import Chinese geographic data into geo model'
  task :import do
    geo_files = Dir['lib/assets/geo/*.json']
    geo_files.each do |geo_file|
      file = File.read(geo_file)
      data = JSON.parse(file)
      data.each do |d|
        p d['code']
        p d['name']
      end
    end
  end

end
