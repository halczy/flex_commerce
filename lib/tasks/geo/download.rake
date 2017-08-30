namespace :geo do
  desc 'Download Chinese province, city, and district data from data repo'
  task :download do
    progressbar = ProgressBar.create(title: 'Getting Geo Data', total: 8, smoothing: 0.6)

    cn_province = 'https://raw.githubusercontent.com/modood/Administrative-divisions-of-China/master/dist/provinces.json'
    cn_city = 'https://raw.githubusercontent.com/modood/Administrative-divisions-of-China/master/dist/cities.json'
    cn_town = 'https://raw.githubusercontent.com/modood/Administrative-divisions-of-China/master/dist/areas.json'
    cn_street = 'https://raw.githubusercontent.com/modood/Administrative-divisions-of-China/master/dist/streets.json'
    cn_geo_data = [cn_province, cn_city, cn_town, cn_street]

    cn_geo_data.each_with_index do |data_url, idx|
      progressbar.increment
      download = open(data_url)
      IO.copy_stream(download, "lib/assets/geo/#{idx}_#{download.base_uri.to_s.split('/')[-1]}")
      progressbar.increment
    end
  end
end
