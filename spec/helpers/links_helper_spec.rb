require 'rails_helper'

RSpec.describe LinksHelper do
  describe 'address_book' do
    before do
      Rails.configuration.address_book_old = Rails.configuration.address_book
      Rails.configuration.address_book = :address_book
    end

    after do
      Rails.configuration.address_book = Rails.configuration.address_book_old
    end

    it 'returns address book' do
      expect(helper.address_book).to eq(:address_book)
    end
  end

  describe 'link_directory' do
    before do
      Rails.configuration.link_directory_old = Rails.configuration.link_directory
      Rails.configuration.link_directory = :link_directory
    end

    after do
      Rails.configuration.link_directory = Rails.configuration.link_directory_old
    end

    it 'returns link_address' do
      expect(helper.link_directory).to eq(:link_directory)
    end
  end
end
