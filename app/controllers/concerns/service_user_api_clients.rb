# frozen_string_literal: true

# This concern registers the current domain_admin api client
# and the cloud_admin api client.
# Once included in a controller it calls the before_filter and
# register the needed clients inside it.
module ServiceUserApiClients
  def self.included(base)
    # include api client accessor module
    base.send :include, Core::ApiClientAccessor

    base.send :before_filter do
      # try to find domain in db
      friendly_id = FriendlyIdEntry.find_by_class_scope_and_key_or_slug(
        'Domain',
        nil,
        params[:domain_id]
      )
      # what is current scope domain
      scope_domain =
        if friendly_id.nil?
          # requested domain isn't in the db yet
          # use the value given by params or the default domain
          (params[:domain_id] || Rails.configuration.default_domain)
        else
          # use domain key stored in db
          friendly_id.key
        end

      # register domain_admin api client for current scope domain
      register_service_user_api_client(
        Core::ServiceUserApiClientManager.service_user_api_client(scope_domain)
      )
      # register cloud_admin api_client
      register_cloud_admin_api_client(
        Core::ServiceUserApiClientManager.cloud_admin_api_client
      )
    end
  end
end
