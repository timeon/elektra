module Identity
  module Domains
    # This controller implemnts the workflow to create a project
    class CreateWizardController < DashboardController
      before_filter :load_and_authorize_inquiry

      def new
        @project = Identity::ProjectNg.new
        @project.cost_control = {}
        return unless @inquiry
        payload = @inquiry.payload
        @project.attributes = payload
      end

      def create
        project_params = params.fetch(:project_ng, {})
                               .merge(domain_id: @scoped_domain_id)
        cost_params    = project_params.delete(:cost_control)

        # user is not allowed to create a project (maybe)
        # so use admin identity for that!
        @project = Identity::ProjectNg.new(project_params)
        @project.enabled = @project.enabled == 'true'
        @project.escape_attributes!

        if @project.save
          audit_logger.info(current_user, 'has created', @project)

          flash.now[:notice] = "Project #{@project.name} successfully created."
          if @inquiry
            if @inquiry.requester && @inquiry.requester.uid
              # give requester needed roles
              grant_required_roles(@project.id, @inquiry.requester.uid)
            end

            inquiry = services.inquiry.set_inquiry_state(
              @inquiry.id,
              :approved,
              "Project #{@project.name} approved and created \
              by #{current_user.full_name}"
            )
            Identity::RoleAssignmentNg.grant_project_user_role_by_role_name(
              @project.id, inquiry.requester.uid, 'admin'
            )
            render 'identity/domains/create_wizard/create.js'
          else
            # there is no requiry -> current user is the creator
            # of this project. Give current user all needed roles.
            grant_required_roles(@project.id, current_user.id)
            redirect_to :domain
          end
          # clear auth_projects_tree cache
          Rails.cache.delete("#{current_user.token}/auth_projects_tree")
        else
          # put cost_params back into @project where the view can find
          # them to re-render the form
          @project.cost_control = cost_params unless cost_params.nil?

          flash.now[:error] = @project.errors.full_messages.to_sentence
          render action: :new
        end
      end

      def load_and_authorize_inquiry
        return if params[:inquiry_id].blank?
        @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

        if @inquiry
          enforce_permissions('identity:project_create',
                              project: { domain_id: @scoped_domain_id })
        else
          render template: '/identity/domains/create_wizard/not_found'
        end
      end

      def grant_required_roles(project_id, user_id)
        Identity::RoleAssignmentNg.grant_project_user_role_by_role_name(
          project_id, user_id, 'admin'
        )
        Identity::RoleAssignmentNg.grant_project_user_role_by_role_name(
          project_id, user_id, 'member'
        )
        Identity::RoleAssignmentNg.grant_project_user_role_by_role_name(
          project_id, user_id, 'network_admin'
        )
      end
    end
  end
end
