# frozen_string_literal: true

module ServiceLayerNg
  module ImageServices
    # Represents Images Service
    module Member
      def new_member(attributes = {})
        map_to(::Image::Member, attributes)
      end

      def members(image_id)
        api.image.list_image_members(image_id).map_to(::Image::Member)
      end

      ################### Model Interface #################
      def create_member(params)
        return false unless params
        params = params.with_indifferent_access
        api.image.create_image_member(
          params[:image_id], member: params[:member_id]
        ).data
      end

      def update_member(params)
        return false unless params
        params = params.with_indifferent_access
        api.image.update_image_member(
          params[:image_id], params[:member_id], status: params[:status]
        ).data
      end

      def delete_member(params)
        return false unless params
        params = params.with_indifferent_access
        api.image.delete_image_member(
          params[:image_id], params[:member_id]
        )
      end
    end
  end
end
