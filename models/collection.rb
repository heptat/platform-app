require 'mongoid'

class Collection
  include Mongoid::Document

  field :uid, type: String
  field :name, type: String

  validates_presence_of       :uid
  validates_presence_of       :name

  def to_param
    self.uid
  end

end

