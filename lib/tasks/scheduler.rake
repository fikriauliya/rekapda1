namespace :scheduler do
  desc "This task is called by the Heroku scheduler add-on"
  task :fetch_data => :environment do
    puts "Fetch..."

    100.times do
      counter = FetchStatus.first.to_be_updated_index
      if counter > 8225 then
        counter = 0
      end

      puts "Counter #{counter}"
      f = File.open('lib/tasks/indexes.txt')
      counter.times{f.gets}
      line = f.gets
      grand_parent, parent = line.split(" ")[0], line.split(" ")[1]
      f.close

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

      existing_vote = Vote.where(:grand_parent_id => grand_parent, :parent_id => parent).first_or_create(parent_id: parent, grand_parent_id: grand_parent, jokowi_count: jokowi_votes, prabowo_count: prabowo_votes)
      if existing_vote.prabowo_count != prabowo_votes or existing_vote.jokowi_count != jokowi_votes
        puts "Update..."
        existing_vote.prabowo_count = prabowo_votes
        existing_vote.jokowi_count = jokowi_votes
        existing_vote.save
      end

      puts "Grand Parent: " + grand_parent.to_s
      puts "Parent: " + parent.to_s
      # puts "Cities: " + city_names.join(",")
      puts "Prabowo: " + prabowo_votes.to_s
      puts "Jokowi: " + jokowi_votes.to_s
      puts "Total: " + total_votes.to_s

      FetchStatus.first.update(:to_be_updated_index => counter + 1)
    end

    puts "Done.."
  end
end