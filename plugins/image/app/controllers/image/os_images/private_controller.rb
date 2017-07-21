# frozen_string_literal: true

module Image
  module OsImages
    # Private Images
    class PrivateController < OsImagesController
      def publish
        @image = services_ng.image.new_image
        @image.id = params[:private_id]
        @image.publish
        @success = (@image.visibility == 'public')
      end

      protected

      def filter_params
        { sort_key: 'name', visibility: 'private' }
      end
    end
  end
end
