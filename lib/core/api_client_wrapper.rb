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
              args = prepare_params(*args)
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

      # convert hashes and array to url params
      def prepare_params( *args )
        # convert arguments to url params
        args.collect do |arg|
          if arg.is_a?(Array)
            # argument is an array -> join values by &
            arg.join('&')
          elsif arg.is_a?(Hash)
            # arg is an hash -> check if values are plane values
            # select values which are hashes
            data = arg.select { |_k, v| v.is_a?(Array) || v.is_a?(Hash) }
            if data.size.positive?
              # argument contains values which represents data -> do not
              # convert them tu url params.
              arg.to_json
            else
              # argument is a hash with plain values -> join keys and values
              # by k=v&
              arg.to_a.collect { |a| "#{a[0]}=#{a[1]}" }.join('&')
            end
          else
            # argument is a string or number
            arg.to_s
          end
        end
      end

      # Check for response errors
      def handle_response
        response = yield
        raise ::Core::ApiError, response unless response.is_a?(Net::HTTPOK)
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
