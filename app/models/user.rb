class User < ActiveRecord::Base
  has_many :boxes
  has_many :items, through: :boxes
  validates :name, presence: true
  validates :username, uniqueness: true
  validates :email, uniqueness: true
  validates :password, length: {minimum: 8 }
  has_secure_password

  include Slugifiable::InstanceMethods
  extend Slugifiable::ClassMethods

end
