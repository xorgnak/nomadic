require 'nokogiri'
require 'open-uri'

class Scrape
  def initialize h={}
    @json = {}
    if h[:uri]
      @node = Nokogiri(open(h[:url]))
    elsif h[:html]
      @node = Nokogiri(h[:html])
    end
    search_for h[:for]
  end
  def search_for h={}
    h.each_pair do |k,v|
      @json[k] = @node.search(v).text
    end
  end
  def node
    @node
  end
  def json
    @json
  end
end
def scrape h={}
  Scrape.new(h)
end

