module Identity
  module Projects
    # This controller implemnts the workflow to create a project request
    class RequestWizardController < ::DashboardController
      before_filter do
        enforce_permissions('identity:project_request',
                            domain_id: @scoped_domain_id)
      end

      def new
        @project = Identity::ProjectNg.new(
          enabled:  true,
          parent_id:  @scoped_project_id,
          parent_name: @scoped_project_name,
          cost_control: {}
        )

        return unless services.available?(:cost_control)
        @cost_control_masterdata = services.cost_control.new_project_masterdata
      end

      def create
        project_params = params.fetch(:project_ng, {})
                               .merge(domain_id: @scoped_domain_id)
        @project = Identity::ProjectNg.new(project_params)

        if @project.valid?
          resource_admins = service_user_ng do
            Identity::UserNg.list_scope_resource_admins(
              domain_id: @scoped_domain_id
            )
          end

          begin
            inquiry = services.inquiry.create_inquiry(
                'project',
                "#{@project.name} - #{@project.description}",
                current_user,
                @project.attributes.to_json,
                resource_admins,
                {
                    "approved": {
                        "name": "Approve",
                        "action": "#{plugin('identity').domain_url(host: request.host_with_port, protocol: request.protocol)}?overlay=#{plugin('identity').domains_create_project_path(project_id: nil)}"
                    }
                },
                nil, #no domain override
                {
                    domain_name: @scoped_domain_name,
                    region: current_region
                }
            )
            unless inquiry.errors?
              flash.now[:notice] = "Project request successfully created"
              audit_logger.info(current_user, "has requested project #{@project.attributes}")
              render template: 'identity/projects/request_wizard/create.js'
            else
              render action: :new
            end
          rescue => e
            @project.errors.add("message",e.message)
            render action: :new
          end
        else
          render action: :new
        end
      end
    end

    def edit
      payload = @inquiry.payload
      @project = Identity::Project.new(nil, {})
      if services.available?(:cost_control)
        @cost_control_masterdata = services.cost_control.new_project_masterdata(payload.delete(:cost_control))
      end
      @project.attributes = payload
    end

    def update
      # user is not allowed to create a project (maybe)
      # so use admin identity for that!
      @project = Identity::Project.new(nil,{})
      @project.attributes = params.fetch(:project, {}).merge(domain_id: @scoped_domain_id)
      if @project.valid?
        inquiry = services.inquiry.change_inquiry(
            id: @inquiry.id,
            description: @project.description,
            payload: @project.attributes.to_json
        )
        unless inquiry.errors?
          render template: 'identity/projects/request_wizard/create.js'
        else
          render action: :edit
        end
      else
        render action: :edit
      end
    end

    def load_and_authorize_inquiry
      @inquiry = services.inquiry.get_inquiry(params[:inquiry_id])

      if @inquiry
        unless current_user.is_allowed?("identity:project_request", {domain_id:@scoped_domain_id})
          render template: '/dashboard/not_authorized'
        end
      else
        render template: '/identity/projects/create_wizard/not_found'
      end
    end

  end
end
