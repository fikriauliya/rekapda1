namespace :scheduler do
  def update_votes(location)
    begin
      grand_parent = location.kabupaten_id
      parent = location.kecamatan_id
      puts("Fetch #{location.province.name} > #{location.kabupaten.name} > #{location.kecamatan.name}")

      response = HTTParty.get("http://pilpres2014.kpu.go.id/da1.php?cmd=select&grandparent=#{grand_parent}&parent=#{parent}")
      # puts response.body
      doc = Nokogiri::HTML(response.body)
      last_table = doc.search('table').last

      # table_headers = last_table.xpath("tr[3]/th")
      # city_names = table_headers[2..-1].map { |h| h.children.to_s}
      prabowo_votes = last_table.xpath("tr[4]/td")[-1].children.to_s.to_i
      jokowi_votes = last_table.xpath("tr[5]/td")[-1].children.to_s.to_i
      total_votes = last_table.xpath("tr[6]/td")[-1].children.to_s.to_i
      puts "Prabowo: " + prabowo_votes.to_s
      puts "Jokowi: " + jokowi_votes.to_s
      puts "Total: " + total_votes.to_s

      location.last_fetched_at = Time.now

      if location.prabowo_count != prabowo_votes or location.jokowi_count != jokowi_votes
        puts "Update..."
        location.prabowo_count = prabowo_votes
        location.jokowi_count = jokowi_votes
        location.save
      end
    rescue Exception => e
      puts e.message
    end
  end

  def update_db1(db1)
    begin
      grand_parent = db1.province_id
      parent = db1.kabupaten_id
      puts("Fetch #{db1.province.name} > #{db1.kabupaten.name}")

      response = HTTParty.get("http://pilpres2014.kpu.go.id/db1.php?cmd=select&grandparent=#{grand_parent}&parent=#{parent}")
      # puts response.body
      doc = Nokogiri::HTML(response.body)
      last_table = doc.search('table').last

      # table_headers = last_table.xpath("tr[3]/th")
      # city_names = table_headers[2..-1].map { |h| h.children.to_s}
      prabowo_votes = last_table.xpath("tr[4]/td")[-1].children.to_s.to_i
      jokowi_votes = last_table.xpath("tr[5]/td")[-1].children.to_s.to_i
      total_votes = last_table.xpath("tr[6]/td")[-1].children.to_s.to_i
      puts "Prabowo: " + prabowo_votes.to_s
      puts "Jokowi: " + jokowi_votes.to_s
      puts "Total: " + total_votes.to_s

      db1.last_fetched_at = Time.now

      if db1.prabowo_count != prabowo_votes or db1.jokowi_count != jokowi_votes
        puts "Update..."
        db1.prabowo_count = prabowo_votes
        db1.jokowi_count = jokowi_votes
        db1.save
      end
    rescue Exception => e
      puts e.message
    end
  end

  desc "Fetch not retrieved db1 only"
  task :fetch_not_retrieved_db1 => :environment do
    puts "Fetch..."
    @db1s = Db1.includes([:province, :kabupaten]).where(:last_fetched_at => nil)

    Parallel.each(@db1s, :in_threads => 8) do |db1|
      update_db1(db1)
    end
    puts "Done.."
  end

  desc "Fetch retrieved db1 only"
  task :fetch_retrieved_db1 => :environment do
    puts "Fetch..."
    @db1s = Db1.includes([:province, :kabupaten]).where('last_fetched_at IS NOT NULL')

    Parallel.each(@db1s, :in_threads => 8) do |db1|
      update_db1(db1)
    end
    puts "Done.."
  end

  desc "Fetch not retrieved da1 only"
  task :fetch_not_retrieved_votes => :environment do
    puts "Fetch..."
    @locations = Location.includes([:kecamatan, :province, :kabupaten]).where(:last_fetched_at => nil)

    Parallel.each(@locations, :in_threads => 8) do |location|
      update_votes(location)
    end
    puts "Done.."
  end

  desc "Fetch retrieved da1 only"
  task :fetch_retrieved_votes => :environment do
    puts "Fetch..."
    @locations = Location.includes([:kecamatan, :province, :kabupaten]).where('last_fetched_at IS NOT NULL')

    Parallel.each(@locations, :in_threads => 8) do |location|
      update_votes(location)
    end
    puts "Done.."
  end

  desc "This task is called by the Heroku scheduler add-on"
  task :fetch_votes => :environment do
    puts "Fetch..."
    max_counter = Location.count/6

    max_counter.times do
      counter = FetchStatus.first.to_be_updated_index
      if counter > max_counter then
        counter = 0
      end

      location = Location.offset(counter).first
      update_votes(location)
      FetchStatus.first.update(:to_be_updated_index => location.id + 1)
    end
    puts "Done.."
  end

  desc "Fetch indexes"
  task :fetch_indexes do
    fetch_province
  end

  desc "Fetch all unretrieved votes"
  task :fetch_all_not_retrieved => :environment do
    Rake::Task["scheduler:fetch_not_retrieved_db1"].invoke
    Rake::Task["scheduler:fetch_not_retrieved_votes"].invoke
  end

  desc "Update all retrieved votes"
  task :fetch_all_retrieved => :environment do
    Rake::Task["scheduler:fetch_retrieved_db1"].invoke
    Rake::Task["scheduler:fetch_retrieved_votes"].invoke
  end

  def fetch_province()
    begin
      f_provinces = File.open('lib\tasks\provinces.txt', 'a')

      response = HTTParty.get("http://pilpres2014.kpu.go.id/da1.php")
      doc = Nokogiri::HTML(response.body)

      provinces = Hash.new
      doc.css("select[name=wilayah_id]")[0].children[1..-1].each {|p| provinces[p[:value]] = p.content}
      # puts(provinces)

      provinces.each do |province_id, province_name|
        puts("Province: #{province_name}")
        f_provinces.puts("#{province_id}|#{province_name}")
        fetch_kabupaten(province_id)
      end
    rescue Exception => e
      f_provinces.puts(e.message)
      f_provinces.puts(e.backtrace.inspect)
    ensure
      f_provinces.close
    end
  end

  def fetch_kabupaten(province_id)
    begin
      f_kabupaten = File.open('lib\tasks\kabupatens.txt', 'a')

      response = HTTParty.get("http://pilpres2014.kpu.go.id/da1.php?cmd=select&grandparent=0&parent=#{province_id}")
      doc = Nokogiri::HTML(response.body)

      kabupaten = Hash.new
      doc.css("select[name=wilayah_id]")[0].children[1..-1].each {|p| kabupaten[p[:value]] = p.content}
      # puts(kabupaten)

      kabupaten.each do |kabupaten_id, kabupaten_name|
        puts("Kabupaten: #{kabupaten_name}")
        f_kabupaten.puts("#{kabupaten_id}|#{kabupaten_name}")
        fetch_kecamatan(province_id, kabupaten_id)
      end
    rescue Exception => e
      f_kabupaten.puts(e.message)
      f_kabupaten.puts(e.backtrace.inspect)
    ensure
      f_kabupaten.close
    end
  end

  def fetch_kecamatan(province_id, kabupaten_id)
    begin
      f_kecamatan = File.open('lib\tasks\kecamatans.txt', 'a')
      f_locations = File.open('lib\tasks\locations.txt', 'a')

      response = HTTParty.get("http://pilpres2014.kpu.go.id/da1.php?cmd=select&grandparent=#{province_id}&parent=#{kabupaten_id}")
      doc = Nokogiri::HTML(response.body)

      kecamatan = Hash.new
      doc.css("select[name=wilayah_id]")[0].children[1..-1].each {|p| kecamatan[p[:value]] = p.content}
      # puts(kecamatan)

      kecamatan.each do |kecamatan_id, kecamatan_name|
        f_kecamatan.puts("#{kecamatan_id}|#{kecamatan_name}")
        f_locations.puts("#{province_id}, #{kabupaten_id}, #{kecamatan_id}")
      end
    rescue Exception => e
      f_kecamatan.puts(e.message)
      f_kecamatan.puts(e.backtrace.inspect)
    ensure
      f_locations.close
      f_kecamatan.close
    end
  end
end