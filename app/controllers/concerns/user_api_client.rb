# frozen_string_literal: true

# This concern registers the current user api client
# Once included in a controller it calls the before_filter and
# register the needed client inside it.
module UserApiClient
  def self.included(base)
    # include api client accessor module
    base.send :include, Core::ApiClientAccessor
    base.send :include, InstanceMethods
  end

  module InstanceMethods
    def set_user_api_client
      client_params = {
        auth: {
          context: {
            catalog: current_user.context['catalog'],
            expires: current_user.context['expires_at'],
            token: current_user.token
          }
        },
        region_id:       current_region,
        ssl_verify_mode: Rails.configuration.ssl_verify_peer,
        log_level:       Logger::INFO,

        # needed because of wrong urls in service catalog.
        # The identity url contains a /v3. This leads to a wrong url in misty!
        identity: { base_path: '/' }
      }
      register_default_api_client(::Misty::Cloud.new(client_params))
    end
  end
end
