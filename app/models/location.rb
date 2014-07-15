class Location < ActiveRecord::Base
  belongs_to :province
  belongs_to :kabupaten
  belongs_to :kecamatan

  def detail_url
    "http://pilpres2014.kpu.go.id/da1.php?cmd=select&grandparent=#{self.kabupaten_id}&parent=#{self.kecamatan_id}"
  end
end
