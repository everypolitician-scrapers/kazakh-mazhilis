
require 'scraperwiki'
require 'open-uri'
require 'nokogiri'

def noko(url)
  Nokogiri::HTML(open(url).read) 
end

BASE = 'http://www.parlam.kz'
START = BASE + '/en/mazhilis/People/DeputyList/A'

@parties = {
  '0' => "Independent",
  '1' => "Nur Otan",
  '14' => "Communist People's Party",
  '17' => "Ak Zhol",
}

noko(START).css('.alphabets li a').each do |letter|
  letter_url = BASE + letter['href']
  puts "Fetching #{letter['href']}"
  noko(letter_url).css('.persons li').each do |person|
    person_url = BASE + person.at_css('a.links/@href').value
    faktion_id = noko(person_url).at_css('.party img/@src').value[/fid=(\d+)/,1].to_s rescue "0"
    data = { 
      id:  (person.at_css('img/@src').value)[/PersonImage\/(\d+)/, 1],
      name: person.at_css('a.links').text,
      party_id: faktion_id,
      party: @parties[faktion_id],
      img: BASE + person.at_css('img/@src').value,
      website: person_url,
      source: letter_url,
    }
    ScraperWiki.save_sqlite([:id], data)
  end
end
