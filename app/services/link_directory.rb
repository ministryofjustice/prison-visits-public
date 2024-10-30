require 'uri_template'

class LinkDirectory
  GOOGLE_MAPS = 'https://google.com/maps?q={query}'
  RATE_SERVICE = 'https://visit-someone-in-prison.form.service.justice.gov.uk'
  PRISON_FINDER = 'https://www.gov.uk/government/collections/prisons-in-england-and-wales'

  def google_maps(query)
    URITemplate.new(GOOGLE_MAPS).expand(query:)
  end

  def rate_service
    RATE_SERVICE
  end

  def prison_finder
    PRISON_FINDER
  end
end
