namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"
  task :fetch_votes => :environment do
    puts "Fetch..."
    max_counter = Location.count

    max_counter.times do
      begin
        counter = FetchStatus.first.to_be_updated_index
        if counter > max_counter then
          counter = 0
        end

        puts "Counter #{counter}"
        location = Location.offset(counter).first
        grand_parent, parent = location.kabupaten_id, location.kecamatan_id

        puts "Grand Parent: " + grand_parent.to_s
        puts "Parent: " + parent.to_s

        # grand_parent = 1492
        # parent = 1493
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
      ensure
        FetchStatus.first.update(:to_be_updated_index => counter + 1)
      end
    end

    puts "Done.."
  end

  desc "Fetch indexes"
  task :fetch_indexes do
    fetch_province
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