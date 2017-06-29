# frozen_string_literal: true

module Identity
  # This class represents the user
  class UserNg < Core::ModelNG
    def self.group_users(group_id, filter = {})
      api.identity.list_users_in_group(group_id, filter).map_to(self)
    end
  end
end
