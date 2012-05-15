class Daccess < ActiveRecord::Base
  def self.appkey
    "xxxx"
  end

  def self.appsecret
    "xxxx"
  end

  def self.accesstype
    :dropbox
  end
end