# frozen_string_literal: true

module Image
  # Implements Image actions
  class OsImagesController < ::Image::ApplicationController
    def index
      @images = paginatable(per_page: 15) do |pagination_options|
        services_ng.image.images(filter_params.merge(pagination_options))
      end

      # this is relevant in case an ajax paginate call is made.
      # in this case we don't render the layout, only the list!
      if request.xhr?
        render partial: 'list', locals: { images: @images }
      else
        # comon case, render index page with layout
        render action: :index
      end
    end

    def show
      @image = services_ng.image.find_image(params[:id])

      properties = @image.attributes.clone.stringify_keys
      known_attributes = %w[
        name id status visibility protected size
        container_format disk_format created_at updated_at owner
      ]
      known_attributes.each { |known| properties.delete(known) }
      additional_properties = properties.delete('properties')
      properties.merge!(additional_properties) if additional_properties

      @properties = properties.sort_by { |k, _v| k }
    end

    def destroy
      @image = services_ng.image.new_image
      @image.id = params[:id]
      @success = (@image && @image.destroy)
    end

    protected

    def filter_params
      raise 'has to be implemented in subclass'
    end
  end
end
