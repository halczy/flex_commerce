namespace :geo do
  desc 'Fetch Chinese province, city, and district data from data repo'
  task :fetch do
    # Track download progress
    progressbar = ProgressBar.create(title: 'Getting Geo Data', total: 8,
                                     format: '%a %B %p%% %t')

    # Store json data urls
    cn_province = 'https://bitbucket.org/!api/2.0/snippets/halczy/g9yK9j/2fe463050cce6de8d27d58264617a64bbaed73be/files/provinces.json'
    cn_city = 'https://bitbucket.org/!api/2.0/snippets/halczy/g9yK9j/2fe463050cce6de8d27d58264617a64bbaed73be/files/cities.json'
    cn_town = 'https://bitbucket.org/api/2.0/snippets/halczy/g9yK9j/2fe463050cce6de8d27d58264617a64bbaed73be/files/areas.json'
    cn_street = 'https://bitbucket.org/!api/2.0/snippets/halczy/g9yK9j/2fe463050cce6de8d27d58264617a64bbaed73be/files/streets.json'
    cn_geo_data = [cn_province, cn_city, cn_town, cn_street]

    # Save each json file to assets folder
    cn_geo_data.each_with_index do |data_url, idx|
      progressbar.increment
      download = open(data_url)
      IO.copy_stream(download, "lib/assets/geo/#{idx}_#{download.base_uri.to_s.split('/')[-1]}")
      progressbar.increment
    end
  end
end
