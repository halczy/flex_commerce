namespace :geo do
  desc 'Import Chinese geographic data into geo model'
  task :import => :environment do
    # Task import progress
    progressbar = ProgressBar.create(title: 'Importing Geo Data', total: 46180,
                                     format: '%a %B %p%% %t')

    # Get json file list from assets folder
    geo_files = Dir['lib/assets/geo/*.json']

    # Create country record
    Geo.create(id: '86', name: '中国', level: 0)

    # Init current geo level (Province, City, Town/Village, Street)
    current_level = 0

    # Go through each json file and create geo record
    geo_files.each do |geo_file|
      file = File.read(geo_file)
      records = JSON.parse(file)
      current_level += 1
      records.each do |record|
        Geo.new.tap do |geo|
          geo.id = record['code']
          geo.name = record['name']
          geo.parent_id = record['parent_code'] ? record['parent_code'] : '86'
          geo.level = current_level
          geo.save
          progressbar.increment
        end
      end
    end

    progressbar.finish
  end

end
