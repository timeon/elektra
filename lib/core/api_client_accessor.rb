# frozen_string_literal: true

module Core
  # this module implements the access to different
  # misty api clients.
  module ApiClientAccessor
    class UnknownClient < StandardError; end

    # stores all available api clients.
    def self.api_client_registry
      RequestStore.store[:api_clients] ||= {}
    end

    # register a new client by name
    def self.register_api_client(name, api_client)
      api_client_registry[name] = api_client
    end

    # returns currently active client
    def self.current_api_client
      RequestStore.store[:api_client]
    end

    # sets active api client
    def self.current_api_client=(api_client)
      RequestStore.store[:api_client] = api_client
    end

    # returns client by name
    def self.api_client(name)
      api_client_registry[name]
    end

    # This methods switches current api client to another.
    # It expects a client name and a block. The active client
    # will be changed, the block executed and after that it switches
    # the client back.
    def self.switch_api_client(name)
      unless api_client_registry[name]
        raise UnknownClient, "API Client #{name} is not registered"
      end

      last_client = current_api_client
      self.current_api_client = api_client_registry[name]
      result = yield if block_given?
      self.current_api_client = last_client
      result
    end

    def self.included(base)
      base.send :include, InstanceMethods
      base.extend ClassMethods
    end

    # Instance methods which are included in the base class.
    module InstanceMethods
      def all_api_clients
        ApiClientAccessor.api_client_registry
      end

      # register user client
      def register_default_api_client(api_client)
        ApiClientAccessor.register_api_client('default', api_client)
      end

      # register domain admin client
      def register_service_user_api_client(api_client)
        ApiClientAccessor.register_api_client('domain_admin', api_client)
      end

      # register cloud admin client
      def register_cloud_admin_api_client(api_client)
        ApiClientAccessor.register_api_client('cloud_admin', api_client)
      end

      # returns active client
      def api_client
        ApiClientAccessor.current_api_client ||
          ApiClientAccessor.api_client('default')
      end

      # this method switches the api_client to service user
      # Usage: service_user {...} or service_user :as_cloud_admin {...}
      # TODO: rename: remove _ng
      def service_user_ng(role = :as_domain_admin, &block)
        case role
        when :as_cloud_admin
          ApiClientAccessor.switch_api_client('cloud_admin', &block)
        else
          ApiClientAccessor.switch_api_client('domain_admin', &block)
        end
      end
    end

    # class methods
    module ClassMethods
      # returns active client
      def api_client
        ApiClientAccessor.current_api_client ||
          ApiClientAccessor.api_client('default')
      end
    end
  end
end
