# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

CONN = ActiveRecord::Base.connection

def populate_key_value_data(table_name)
  inserts = []
  File.open("lib/tasks/#{table_name}.txt", "r").each_line do |line|
    id, name = line.split("|")
    name = name.strip.gsub("'", "''")
    inserts.push("(#{id}, '#{name}')")
  end

  slices = inserts.each_slice(100).to_a
  slices.each do |slice|
    sql = "INSERT INTO #{table_name}(id, name) VALUES #{slice.join(',')}"
    CONN.execute(sql)
  end
end

def populate_locations
  inserts = []
  File.open("lib/tasks/locations.txt", "r").each_line do |line|
    province_id, kabupaten_id, kecamatan_id = line.split(",").map{|l| l.strip.gsub("'", "''")}
    inserts.push("(#{province_id}, #{kabupaten_id}, #{kecamatan_id})")
  end

  slices = inserts.each_slice(100).to_a
  slices.each do |slice|
    sql = "INSERT INTO locations(province_id, kabupaten_id, kecamatan_id) VALUES #{slice.join(',')}"
    CONN.execute(sql)
  end
end

FetchStatus.delete_all
Province.delete_all
Kabupaten.delete_all
Kecamatan.delete_all
Location.delete_all

FetchStatus.create(to_be_updated_index: 0)
["provinces", "kabupatens", "kecamatans"].each{|v| populate_key_value_data(v)}
populate_locations