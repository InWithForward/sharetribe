PaperTrail::Rails::Engine.eager_load!
PaperTrail.serializer = PaperTrail::Serializers::JSON

module PaperTrail
  class Version < ActiveRecord::Base
    attr_accessible :customizable_id, :customizable_type, :customizable
  end
end
