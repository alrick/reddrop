class Daccess < ActiveRecord::Base
  def self.appkey
    "6chg87440bmg0yr"
  end

  def self.appsecret
    "o8n4jk1udoy23ey"
  end

  def self.accesstype
    :dropbox
  end
end