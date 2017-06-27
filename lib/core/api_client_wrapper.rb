# frozen_string_literal: true

module Core
  # Wrapper for Api Client
  class ApiClientWrapper
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
        if data.is_a?(Array)
          data.collect { |item| klazz.new(item.merge(options)) }
        elsif data.is_a?(Hash)
          klazz.new(data.merge(options))
        else
          data
        end
      end
    end

    # Wrapper for Service
    class Service
      delegate :requests, to: :@origin_service
      attr_reader :origin_service

      def initialize(api_service)
        @origin_service = api_service
        # define missing methods fosr requests and
        # delegate them to api_service
        api_service.requests.each do |meth|
          (class << self; self; end).class_eval do
            define_method meth do |*args|
              args = prepare_params(*args)
              handle_response do
                api_service.send meth, *args
              end
            end
          end
        end
      end

      # convert hashes and array to url params
      def prepare_params( *args )
        args.collect do |arg|
          if arg.is_a?(Array)
            arg.join('&')
          elsif arg.is_a?(Hash)
            data = arg.select { |_k, v| v.is_a?(Array) || v.is_a?(Hash) }
            if data.size.positive?
              arg.to_json
            else
              arg.to_a.collect { |a| "#{a[0]}=#{a[1]}" }.join('&')
            end
          else
            arg.to_s
          end
        end
      end

      # Check for response errors
      def handle_response
        response = yield
        unless response.is_a?(Net::HTTPOK)
          raise ::Core::ServiceLayer::Errors::ApiError,
                "API ERROR: #{response.body}"
        end
        ApiClientWrapper::Response.new(response)
      end
    end

    def initialize(misty)
      # define methods for all services and delegate them to
      # origin api client
      Misty.services.collect(&:name).each do |meth|
        (class << self; self; end).class_eval do
          define_method meth do |*args|
            unless instance_variable_get("@#{meth}")
              service = ApiClientWrapper::Service.new(misty.send(meth, *args))
              instance_variable_set("@#{meth}", service)
            end
            instance_variable_get("@#{meth}")
          end
        end
      end
    end
  end
end
