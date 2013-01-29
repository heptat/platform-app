require 'mongoid'

class User
  include Mongoid::Document

  field :uid, type: String
  field :collections, type: Array

  validates_presence_of       :uid

  def to_param
    self.uid
  end

end

