class Vote < ActiveRecord::Base
  def detail_url
    "http://pilpres2014.kpu.go.id/da1.php?cmd=select&grandparent=#{self.grand_parent_id}&parent=#{self.parent_id}"
  end
end
