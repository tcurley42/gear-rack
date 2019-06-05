class User < ActiveRecord::Base
  has_many :boxes
  has_many :items, through: :boxes
  validates :name, presence: true
  validates :username, uniqueness: true
  has_secure_password

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
