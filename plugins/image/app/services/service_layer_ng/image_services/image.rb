# frozen_string_literal: true

module ServiceLayerNg
  module ImageServices
    # Represents Images Service
    module Image
      def new_image(attributes = {})
        map_to(::Image::Image, attributes)
      end

      # use this with pagination options, otherwise you will get a maxium
      # of 25 images (glance default limit)
      def images(filter = {})
        api.image.show_images(filter).map_to(::Image::Image)
      end

      def all_images(filter = {})
        all_images = images(filter)
        last_image = all_images.last

        if last_image
          # we have always pagination in glance (default limit 25),
          # so we need to loop over all pages
          while (images_page = images(filter.merge(marker: last_image.id))).count.positive?
            last_image = images_page.last
            all_images += images_page
          end
        end

        all_images
      end

      def find_image!(id)
        return nil if id.blank?
        api.image.show_image_details(id).map_to(body: ::Image::Image)
      end

      def find_image(id)
        find_image!(id)
      rescue
        nil
      end

      #################### Model Interface #####################
      def create_image(attributes)
        api.image.create_an_image(attributes).data
      end

      def update_image(id, attributes)
        api.image.update_an_image(id, [attributes]).data
      end

      def delete_image(id)
        api.image.delete_an_image(id)
      end
    end
  end
end
