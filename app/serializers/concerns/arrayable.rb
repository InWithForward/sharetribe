module Serializers
  module Concerns
    module Arrayable
      def array(objects)
        objects.map { |obj| hash(obj) }
      end
    end
  end
end

