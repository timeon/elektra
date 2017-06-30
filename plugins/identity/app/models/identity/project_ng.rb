# frozen_string_literal: true

module Identity
  # This class represents the project and it also
  # implements the communication with the api.
  class ProjectNg < Core::ModelNG
    # load user projects from api
    def self.user_projects(user_id, filter = {})
      api.identity.list_projects_for_user(user_id, filter).map_to(self)
    end

    def self.auth_projects(domain_id = nil)
      projects = api.identity.get_available_project_scopes.map_to(self)

      return projects if domain_id.nil?
      projects.select { |project| project.domain_id == domain_id }
    end

    # load project from api
    def self.find(id, filter = {})
      api.identity.show_project_details(id, filter).map_to(self)
    end

    def self.all(filter = {})
      api.identity.list_projects(filter).map_to(self)
    end

    def friendly_id
      return nil if id.nil?
      return id if domain_id.blank? || name.blank?

      friendly_id_entry = FriendlyIdEntry
                          .find_or_create_entry('Project', domain_id, id, name)
      friendly_id_entry.slug
    end

    #################### API ####################
    def perform_create
      params = attributes_for_save(
        %i[is_domain description domain_id enabled name parent_id]
      )
      api.identity.create_project(project: params)
    end

    def perform_update
      params = attributes_for_save(
        %i[is_domain description domain_id enabled name]
      )
      api.identity.update_project(id, project: params)
    end

    def perform_destroy
      api.identity.update_project(id)
    end
  end
end
