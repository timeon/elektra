# frozen_string_literal: true

module Core
  # this class manages the api clients for service user.
  # The client is created for each domain (organization) and
  # stored in class variable.
  class ServiceUserApiClientManager
    @domain_admin_api_client_mutex = Mutex.new
    @cloud_admin_api_client_mutex = Mutex.new

    def self.region_from_auth_url(auth_url = ::Core.keystone_auth_endpoint)
      data = /.+\.(?<region>[^\.]+)\.cloud\.sap/.match(auth_url)
      data[:region]
    end

    def self.domain_admin_api_client(scope_domain)
      return nil if scope_domain.nil?

      @domain_admin_api_client_mutex.synchronize do
        @domain_admin_api_clients ||= {}

        # the service user clients are created per domain (organization)
        # and are stored in class variable
        unless @domain_admin_api_clients[scope_domain]
          @domain_admin_api_clients[scope_domain] =
            create_domain_admin_api_client(scope_domain)
        end
      end
      @domain_admin_api_clients[scope_domain]
    end

    def self.cloud_admin_api_client
      unless @cloud_admin_api_client
        @cloud_admin_api_client_mutex.synchronize do
          @cloud_admin_api_client = create_cloud_admin_api_client
        end
      end
      @cloud_admin_api_client
    end

    def self.create_domain_admin_api_client(scope_domain)
      misty_params = {
        auth: {
          url:            ::Core.keystone_auth_endpoint,
          user:           Rails.application.config.service_user_id,
          user_domain:    Rails.application.config.service_user_domain_name,
          password:       Rails.application.config.service_user_password,
          domain:         scope_domain
        },
        identity: { base_path: '/' },
        region_id: Rails.application.config.default_region ||
                   region_from_auth_url
      }

      begin
        Misty::Cloud.new(misty_params)
      rescue Misty::Auth::AuthenticationError => _e
        unless misty_params[:auth][:domain_id]
          misty_params[:auth].delete(:domain)
          misty_params[:auth][:domain_id] = scope_domain
        end
        retry
      end
    end

    def self.create_cloud_admin_api_client
      Misty::Cloud.new(
        auth: {
          url:            ::Core.keystone_auth_endpoint,
          user:           Rails.application.config.service_user_id,
          user_domain:    Rails.application.config.service_user_domain_name,
          password:       Rails.application.config.service_user_password,
          project:        Rails.configuration.cloud_admin_project,
          project_domain: Rails.configuration.cloud_admin_domain
        },
        identity: { base_path: '/' },
        log_level: Logger::INFO,
        region_id: Rails.application.config.default_region ||
                   region_from_auth_url
      )
    end
  end
end
