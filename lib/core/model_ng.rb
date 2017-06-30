# frozen_string_literal: true

require_relative 'strip_attributes'

module Core
  # This class implements the basic functionality for api models.
  # The API response is mapped to a subclass of this class.
  # TODO: rename: remove _ng
  class ModelNG
    extend ActiveModel::Naming
    extend ActiveModel::Translation
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include Core::StripAttributes
    include ActiveModel::Validations::Callbacks

    class MissingAttribute < StandardError; end

    strip_attributes

    attr_reader :errors
    attr_accessor :id

    def initialize(params = nil)
      self.attributes = params
      # get just the name of class without namespaces
      @class_name = self.class.name.split('::').last.underscore
      # create errors object
      @errors = ActiveModel::Errors.new(self)
      # execute after callback
      after_initialize
    end

    # wrap api client
    def api
      Core::ApiClientWrapper
    end

    # wrap class api client
    def self.api
      Core::ApiClientWrapper
    end

    def attributes
      { id: @id }.merge(@attributes)
    end

    def as_json(_options = nil)
      attributes
    end

    # look in attributes if a method is missing
    def method_missing(method_sym, *arguments, &block)
      attribute_name = method_sym.to_s
      if attribute_name.ends_with?('=')
        attribute_name = attribute_name.chop
        write(attribute_name, arguments.first)
      elsif attribute_name.length > 2
        read(attribute_name)
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      keys = @attributes.keys
      method_name.to_s == 'id' ||
        keys.include?(method_name.to_s) ||
        keys.include?(method_name.to_sym) ||
        super
    end

    def requires(*attrs)
      attrs.each do |attribute|
        if send(attribute.to_s).nil?
          raise MissingAttribute, "#{attribute} is missing"
        end
      end
    end

    def attributes_for_save(names = [])
      names.each_with_object({}) do |name, hash|
        value = @attributes[name.to_sym] || @attributes[name.to_s]
        hash[name.to_s] = value if value
      end
    end

    def save
      # execute before callback
      before_save

      success = valid?

      if success
        success = id.nil? ? perform_save(:create) : perform_save(:update)
      end

      success & after_save
    end

    def update(attributes = {})
      attributes.each { |key, value| send("#{key}=", value) }
      save
    end

    def perform_save(mod)
      rescue_api_errors do
        new_attributes = if mod == :create
                           perform_create
                         elsif mod == :update
                           perform_update
                         end
        if new_attributes.is_a?(::Core::ApiClientWrapper::Service::Response)
          new_attributes = new_attributes.data
        end

        self.attributes = new_attributes
      end
    end

    def destroy
      rescue_api_errors { perform_destroy }
    end

    def rescue_api_errors
      yield
      true
    rescue ::Core::ApiError => e
      e.messages.each { |m| errors.add('api', m) }
      false
    end

    def attributes=(new_attributes)
      @attributes = (new_attributes || {}).clone
      # delete id from attributes!
      new_id = nil
      if @attributes['id'] || @attributes[:id]
        new_id = (@attributes.delete('id') || @attributes.delete(:id))
      end
      # if current_id is nil then overwrite it with new_id.
      @id = new_id if @id.nil? || (@id.is_a?(String) && @id.empty?)
    end

    def escape_attributes!
      escaped_attributes = (@attributes || {}).clone
      escaped_attributes.each { |k, v| @attributes[k] = escape_value(v) }
    end

    def before_save
      true
    end

    def after_initialize
      true
    end

    def after_save
      true
    end

    def created_at
      value = read('created') || read('created_at')
      DateTime.parse(value) if value
    end

    def pretty_created_at
      Core::Formatter.format_modification_time(created_at) if created_at
    end

    def updated_at
      value = read('updated') || read('updated_at')
      DateTime.parse(value) if value
    end

    def pretty_updated_at
      Core::Formatter.format_modification_time(updated_at) if updated_at
    end

    def write(attribute_name, value)
      @attributes[attribute_name.to_s] = value
    end

    def read(attribute_name)
      value = @attributes[attribute_name.to_s]
      value = @attributes[attribute_name.to_sym] if value.nil?
      value
    end

    def escape_value(value)
      value = CGI.escapeHTML(value) if value.is_a?(String)
      value
    end

    def pretty_attributes
      JSON.pretty_generate(@attributes.merge(id: id))
    end

    def to_s
      pretty_attributes
    end

    def debug(*args)
      self.class.debug(*args)
    end

    def self.debug(message)
      puts message if ENV['MODEL_DEBUG']
    end
  end
end
