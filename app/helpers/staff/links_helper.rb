module Staff::LinksHelper
  def address_book
    Rails.configuration.address_book
  end

  def pvbcommon_link_directory
    Rails.configuration.pvbcommon_link_directory
  end
end
