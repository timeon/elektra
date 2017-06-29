module HelpTexts
  def load_help_text
    plugin_path = params[:controller]

    plugin_index = Core::PluginsManager.available_plugins.find_index { |p| plugin_path.starts_with?(p.name) }
    plugin = Core::PluginsManager.available_plugins.fetch(plugin_index, nil) unless plugin_index.blank?

    unless plugin.blank?

      # get name of the specific service inside the plugin
      # remove plugin name from path
      path = plugin_path.split('/')
      path.shift
      service_name = path.join('_')

      # try to find the help file, check first for service specific help file,
      # next for general plugin help file
      help_file =  File.join(plugin.path, "plugin_#{service_name}_help.md")
      help_file =  File.join(plugin.path, 'plugin_help.md') unless File.exist?(help_file)

      # try to find the links file, check first for service specific links file,
      # next for general plugin links file
      help_links = File.join(plugin.path, "plugin_#{service_name}_help_links.md")
      help_links = File.join(plugin.path, 'plugin_help_links.md') unless File.exist?(help_links)

      # load plugin specific help text
      @plugin_help_text = File.new(help_file, 'r').read if File.exist?(help_file)

      # load plugin specific help links
      if File.exist?(help_links)
        @plugin_help_links = File.new(help_links, 'r').read
        @plugin_help_links = @plugin_help_links.gsub('#{@sap_docu_url}', sap_url_for('documentation'))
      end
    end
  end
end
