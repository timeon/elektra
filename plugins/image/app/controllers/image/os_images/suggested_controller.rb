# frozen_string_literal: true

module Image
  module OsImages
    # Suggested images
    class SuggestedController < OsImagesController
      before_filter :find_member, only: %i[accept reject]

      def accept
        @success = @member.accept
        render action: :accept, format: :js
      end

      def reject
        @success = @member.reject
        render action: :reject, format: :js
      end

      protected

      def filter_params
        { sort_key: 'name', visibility: 'shared', member_status: 'pending' }
      end

      def find_member
        members = services_ng.image.members(params[:suggested_id])
        @member = members.find do |member|
          member.member_id == @scoped_project_id &&
            member.status == 'pending'
        end
      end
    end
  end
end
