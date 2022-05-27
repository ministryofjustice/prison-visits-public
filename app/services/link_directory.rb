require 'uri_template'

class LinkDirectory
  GOOGLE_MAPS = 'http://google.com/maps?q={query}'
  RATE_SERVICE = 'http://www.gov.uk/done/prison-visits'
  PRISON_FINDER = 'http://www.gov.uk/government/collections/prisons-in-england-and-wales'

  def google_maps(query)
    URITemplate.new(GOOGLE_MAPS).expand(query: query)
  end

  def rate_service
    RATE_SERVICE
  end

  def prison_finder
    PRISON_FINDER
  end
end
