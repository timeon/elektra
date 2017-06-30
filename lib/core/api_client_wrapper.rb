# frozen_string_literal: true

require_relative 'api_error'

module Core
  # Wrapper for Api Client
  class ApiClientWrapper
    # Wrapper for misty services
    class Service
      include ::Core::ApiClientAccessor

      # Wrapper for Response
      class Response
        # delegates some methods to origin response
        delegate :message, :value, :msg, :uri, :code, :header, :body,
                 :http_version, :code_type, :error!, :error_type,
                 :[],
                 to: :@origin_response

        attr_reader :origin_response

        # This method extracts the mapping key and class from params
        # and returns the class and data
        def self.extract_class_and_data(klazz_or_map, response_body)
          if klazz_or_map.is_a?(Hash) && klazz_or_map.keys.length.positive?
            key = klazz_or_map.keys.first
            [klazz_or_map[key], response_body[key]]
          else
            key = response_body.keys.reject do |k|
              %w[links previous next].include?(k)
            end.first
            [klazz_or_map, response_body[key]]
          end
        end

        def initialize(response)
          @origin_response = response
        end

        def data
          key = @origin_response.body.keys.reject do |k|
            %w[links previous next].include?(k)
          end.first
          @origin_response.body[key]
        end

        # This method is used to map raw data to a Object.
        def map_to(klazz_or_map, options = {})
          klazz, data = self.class.extract_class_and_data(klazz_or_map,
                                                          @origin_response.body)

          ApiClientWrapper.map_to(klazz, data, options)
        end
      end

      def initialize(name)
        # define missing methods fosr requests and
        # delegate them to api_service
        api_client.send(name).requests.each do |meth|
          (class << self; self; end).class_eval do
            define_method meth do |*args|
              handle_response do
                api_client.send(name).send(meth, *args)
              end
            end
          end
        end
      end

      def requests
        api_client.send(name).requests
      end

      # Check for response errors
      def handle_response
        response = yield
        raise ::Core::ApiError, response if response.code.to_i >= 400
        Response.new(response)
      end
    end

    # This method is used to map raw data to a Object.
    def self.map_to(klazz, data, options = {})
      if data.is_a?(Array)
        data.collect { |item| klazz.new(item.merge(options)) }
      elsif data.is_a?(Hash)
        klazz.new(data.merge(options))
      else
        data
      end
    end

    # create class methods for each service.
    # identity, compute, networking ....
    Misty.services.collect(&:name).each do |name|
      define_singleton_method name do
        # cache services in class variables.
        # The api_client is globaly available. The service
        # only defines the proxy methods. Inside this methods
        # the global api_client is called.
        unless instance_variable_get("@service_#{name}")
          instance_variable_set("@service_#{name}", Service.new(name))
        end
        instance_variable_get("@service_#{name}")
      end
    end
  end
end
