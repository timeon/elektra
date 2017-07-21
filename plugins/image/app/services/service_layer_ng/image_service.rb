# frozen_string_literal: true

module ServiceLayerNg
  # Implements the Openstack Glance API
  class ImageService < Core::ServiceLayerNg::Service
    include ImageServices::Image
    include ImageServices::Member

    def available?(_action_name_sym = nil)
      api.catalog_include_service?('glance', region)
    end
  end
end
