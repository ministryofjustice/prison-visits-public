Rails.application.config.to_prepare do
  Rails.configuration.link_directory = LinkDirectory.new
end
