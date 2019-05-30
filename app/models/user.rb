class User < ActiveRecord::Base
  has_many :boxes
  has_many :items, through: :boxes
  has_secure_password

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
