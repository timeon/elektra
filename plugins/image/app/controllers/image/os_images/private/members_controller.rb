# frozen_string_literal: true

module Image
  module OsImages
    module Private
      # Implements Image members
      class MembersController < ::Image::ApplicationController
        def index
          @image = services_ng.image.find_image(params[:private_id])
          @members = services_ng.image.members(params[:private_id])
        end

        def create
          member_id_or_name = params[:member][:member_id]
          @image = services_ng.image.find_image(params[:private_id])
          @project = service_user.identity.find_project_by_name_or_id(
            @scoped_domain_id, member_id_or_name
          )
          @member = services_ng.image.new_member(
            image_id: @image.try(:id),
            member_id: @project.try(:id)
          )
          @member.save
        end

        def destroy
          @member = services_ng.image.new_member(
            image_id: params[:private_id], member_id: params[:id]
          )
          @member.destroy
        end
      end
    end
  end
end
