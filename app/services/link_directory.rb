require 'uri_template'

class LinkDirectory
  GOOGLE_MAPS = 'http://google.com/maps?q={query}'
  RATE_SERVICE = 'http://www.gov.uk/done/prison-visits'

  def google_maps(query)
    URITemplate.new(GOOGLE_MAPS).expand(query: query)
  end

  def rate_service
    RATE_SERVICE
  end
end
