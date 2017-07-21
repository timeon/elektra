# frozen_string_literal: true

module Image
  # Describes openstack image
  class Image < Core::ServiceLayerNg::Model
    def publish
      rescue_api_errors do
        new_attributes = @service.update_image(
          id, op: 'replace', path: '/visibility', value: 'public'
        )
        self.attributes = new_attributes
        true
      end
    end

    def unpublish
      rescue_api_errors do
        new_attributes = @service.update_image(
          id, op: 'replace', path: '/visibility', value: 'private'
        )
        self.attributes = new_attributes
        true
      end
    end
  end
end
