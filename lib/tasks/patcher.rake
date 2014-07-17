namespace :patcher do
  desc "Populate DB1"
  task :populate_db1 => :environment do
    CONN = ActiveRecord::Base.connection

    inserts = []
    File.open("lib/tasks/province_kabupaten.txt", "r").each_line do |line|
      province_id, kabupaten_id = line.split(",").map{|l| l.strip.gsub("'", "''")}
      inserts.push("(#{province_id}, #{kabupaten_id})")
    end

    slices = inserts.each_slice(100).to_a
    slices.each do |slice|
      sql = "INSERT INTO db1s(province_id, kabupaten_id) VALUES #{slice.join(',')}"
      CONN.execute(sql)
    end
  end
end