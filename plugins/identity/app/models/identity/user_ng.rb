# frozen_string_literal: true

module Identity
  # This class represents the user
  class UserNg < Core::ModelNG
    def self.find(user_id)
      api.identity.show_user_details(user_id).map_to(self)
    end

    def self.group_users(group_id, filter = {})
      api.identity.list_users_in_group(group_id, filter).map_to(self)
    end

    # A special case of list_scope_admins that returns a list of CC admins.
    def self.list_ccadmins
      domain_name = Rails.configuration.cloud_admin_domain
      in_domain_scope(domain_name) do
        domain_id = @auth_users[domain_name].domain_id
        list_scope_admins(domain_id: domain_id)
      end
    end

    def self.list_scope_resource_admins(scope = {})
      role = begin
               Identity::RoleNg.find_by_name('resource_admin')
             rescue
               nil
             end
      list_scope_assigned_users(scope.merge(role: role))
    end

    # Returns admins for the given scope (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID)
    # This method looks recursively for project, parent_projects and domain admins until it finds at least one.
    # It should always return a non empty list (at least the domain admins).
    def self.list_scope_admins(scope = {})
      role = begin
               Identity::RoleNg.find_by_name('admin')
             rescue
               nil
             end
      list_scope_assigned_users(scope.merge(role: role))
    end

    def self.list_scope_assigned_users!(options = {})
      list_scope_assigned_users(options.merge(raise_error: true))
    end

    # Returns assigned users for the given scope and role
    # (e.g. project_id: PROJECT_ID, domain_id: DOMAIN_ID, role: ROLE)
    # This method looks recursively for assigned users of project,
    # parent_projects and domain.
    def self.list_scope_assigned_users(options={})
      admins = []
      project_id = options[:project_id]
      domain_id = options[:domain_id]
      role = options[:role]
      raise_error = options[:raise_error]

      # do nothing if role is nil
      return admins if role.nil?

      begin
        if project_id # project_id is presented
          # get role_assignments for this project_id
          role_assignments = Identity::RoleAssignmentNg.all(
            'scope.project.id' => project_id, 'role.id' => role.id,
            effective: true, include_subtree: true
          )

          # load users (not very performant but there is no other
          # option to get users by ids)
          admins.concat(users_from_role_assignments(role_assignments))

          if admins.length.zero? # no admins for this project_id found
            # load project
            project = begin
                        Identity::ProjectNg.find(project_id)
                      rescue
                        nil
                      end
            if project
              # try to get admins recursively by parent_id
              admins = list_scope_assigned_users(
                project_id: project.parent_id,
                domain_id: project.domain_id,
                role: role
              )
            end
          end
        elsif domain_id # project_id is nil but domain_id is presented
          # get role_assignments for this domain_id
          role_assignments = Identity::RoleAssignmentNg.all(
            'scope.domain.id' => domain_id, 'role.id' => role.id,
            effective: true
          )
          # load users
          admins.concat(users_from_role_assignments(role_assignments))
        end
      rescue => e
        raise e if raise_error
      end

      admins.delete_if { |a| a.id.nil? } # delete crap
    end

    def self.users_from_role_assignments(role_assignments)
      role_assignments.each_with_object([]) do |r, array|
        next if r.user['name'] == Rails.application.config.service_user_id

        begin
          array << find(r.user['id'])
        rescue
          nil
        end
      end
    end
  end
end
