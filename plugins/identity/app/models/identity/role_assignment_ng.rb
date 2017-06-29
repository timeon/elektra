# frozen_string_literal: true

module Identity
  # This class represents the role assignment and it also
  # implements the communication with the api.
  class RoleAssignmentNg < Core::ModelNG
    # load project from api
    def self.all(filter = {})
      effective = filter.delete(:effective) || filter.delete('effective')
      assignments = api.identity.list_role_assignments(filter).map_to(self)
      # return if no effective filter required
      return assignments unless effective

      aggregate_group_role_assignments(assignments)
    end

    def self.aggregate_group_role_assignments(role_assignments)
      role_assignments.each_with_object([]) do |ra, array|
        if ra.user.present?
          array << ra
        elsif ra.group.present?
          Identity::UserNg.group_users(ra.group['id']).collect do |user|
            array << Identity::RoleAssignmentNg.new(
              'role' => ra.role,
              'scope' => ra.scope,
              'user' => { 'id' => user.id }
            )
          end
        end
        array
      end
    end
  end
end
