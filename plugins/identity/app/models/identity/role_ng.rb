# frozen_string_literal: true

module Identity
  # This class represents the user
  class RoleNg < Core::ModelNG
    def self.find_by_name(name)
      all.select { |r| r.name == name }.first
    end

    def self.all(filter = {})
      api.identity.list_roles(filter).map_to(self)
    end
  end
end
