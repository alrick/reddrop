class Accesstoken < ActiveRecord::Base
  
  has_many :projectusers, :dependent => :destroy

end
