# frozen_string_literal: true

module Identity
  # This class represents the project and it also
  # implements the communication with the api.
  class ProjectNg < Core::ModelNG
    # load user projects from api
    def self.user_projects(user_id, filter = {})
      api.identity.list_projects_for_user(user_id, filter).map_to(self)
    end

    # load project from api
    def self.find(id, filter = {})
      api.identity.show_project_details(id, filter).map_to(self)
    end

    def create

    end

    def update
      byebug
      api.identity.update_project(project: attributes).body['project']
    end
  end
end
