# frozen_string_literal: true

module Identity
  # This class represents the domain and it also
  # implements the communication with the api.
  class DomainNg < Core::ModelNG
    # load domain from api
    def self.find(id, filter = {})
      api.identity.show_domain_details(id, filter).map_to(self)
    end

    def self.all(filter = {})
      api.identity.list_domains(filter).map_to(self)
    end

    def friendly_id
      return nil if id.nil?
      return id if name.blank?

      friendly_id_entry = FriendlyIdEntry
                          .find_or_create_entry('Domain', nil, id, name)
      friendly_id_entry.slug
    end
  end
end
