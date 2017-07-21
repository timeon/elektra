# frozen_string_literal: true

module Image
  # Describes Member
  class Member < Core::ServiceLayerNg::Model
    validates :member_id, presence: true
    validates :image_id, presence: true

    def save
      rescue_api_errors do
        @service.create_member(
          member_id: member_id,
          image_id: image_id
        )
        true
      end
    end

    def destroy
      rescue_api_errors do
        @service.delete_member(
          member_id: member_id,
          image_id: image_id
        )
        true
      end
    end

    def accept
      rescue_api_errors do
        @service.update_member(
          member_id: member_id,
          image_id: image_id,
          status: 'accepted'
        )
        true
      end
    end

    def reject
      rescue_api_errors do
        @service.update_member(
          member_id: member_id,
          image_id: image_id,
          status: 'rejected'
        )
        true
      end
    end
  end
end
