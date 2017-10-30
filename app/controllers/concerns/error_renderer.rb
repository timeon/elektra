# frozen_string_literal: true

# This module adds two methods for exception handling.
# With rescue_and_render_exception_page it is possible to catch
# exceptions and display a well designed exception page.
# The render_exception_page method implements the displaying of an exception.
module ErrorRenderer
  # add instance and class methods after this module was included or extended.
  def self.included(base)
    base.send('extend', ClassMethods)
    base.send('include', InstanceMethods)
  end

  def self.extended(base)
    base.send('extend', ClassMethods)
    base.send('include', InstanceMethods)
  end

  # instance methods
  module InstanceMethods
    def render_exception_page(exception,map={})
      raise exception if Rails.env.development? && ENV.key?('NO_EXCEPTION_PAGE')
      value = lambda do |param|
        v = map[param.to_sym] || map[param.to_s]
        return nil if v.nil?
        return exception.send(v).to_s if v.is_a?(Symbol)
        return v.call(exception, self).to_s if v.is_a?(Proc)
        return v.to_s
      end

      status = if exception.respond_to?(:status)
                 exception.status
               elsif exception.respond_to?(:code)
                 exception.code
               else
                 503
               end

      begin
        @title = value.call(:title) || exception.class.name.split('::').last.humanize
        @description = value.call(:description) || (exception.message rescue exception.to_s)
        @details = value.call(:details) || exception.class.name+"\n"+(exception.backtrace rescue '').join("\n")
        @exception_id = value.call(:exception_id) || request.uuid
        @warning = value.call(:warning) || false
        @status = value.call(:status) || status
      rescue => e
        @title = e.class.name.split('::').last.humanize
        @description = e.message
        @details = e.class.name+"\n"+(e.backtrace rescue '').join("\n")
        @exception_id = request.uuid
        @warning = false
        @status = 503
      end

      unless @warning
        logger.error("#{@exception_id}: #{@title}. #{@description}")

        unless map[:sentry]==false
          Raven::Rack.capture_exception(exception, request.env)
          @exception_id = Raven.last_event_id if Raven.last_event_id
        end
        @sentry_event_id   = Raven.last_event_id
        @sentry_public_dsn = URI.parse(ENV['SENTRY_DSN']).tap {|u| u.password=nil}.to_s if ENV['SENTRY_DSN']
        @sentry_user       = { name: current_user.full_name || current_user.name, email: current_user.email } if current_user

        # no render error if polling service
        unless params[:polling_service]
          respond_to do |format|
            format.html { render '/application/exceptions/error.html' }
            format.js { render "/application/exceptions/error.js" }
            format.json {render json: {error: @description}, status: @status}
          end
        end
      else
        if request.xhr? && params[:polling_service]
          render "/application/exceptions/error_polling.js", format: "JS"
        else
          byebug
          respond_to do |format|
            format.html { render '/application/exceptions/warning.html' }
            format.js { render "/application/exceptions/warning.js" }
            format.json { render json: {error: @description}, status: @status }
          end
        end
      end
    end
  end

  # class methods
  module ClassMethods
    # This method is used in controllers to catch errors and render error page.
    # It differentiates between html, modal, js and polling errors.
    # Request vom Polling service which end up in error will display Flash-Errors.
    # GET-Requests for modal content will show errors inside modal window.
    # JS-POST requests (e.g.: remote: true) will display error dialog.
    def rescue_and_render_exception_page(*exception_classes)
      exception_classes = exception_classes.first if exception_classes.first.is_a?(Array)
      exception_mapping = {}
      klasses = []

      exception_classes.each do |exception_class|
        if exception_class.is_a?(Hash)
          exception_mapping[exception_class.keys.first.to_s]=exception_class.values.first
          klasses << exception_class.keys.first.to_s
        else
          klasses << exception_class
        end
      end

      rescue_from *klasses do |exception|
        map = exception_mapping[exception.class.name]
        unless map
          klass = nil
          exception_mapping.each do |class_name,mapping|
            found_class = eval(class_name)
            next if klass && found_class > klass

            if found_class > exception.class
              map = mapping
            end
          end
          map ||= {}
        end

        render_exception_page(exception,map)
      end
    end
  end
end
