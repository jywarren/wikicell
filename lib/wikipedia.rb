gem "httparty"
require "httparty"

class Wikipedia
  include HTTParty
  base_uri 'en.wikipedia.org'
  format :xml

  # api.php?action=opensearch&search=
  
  def self.search(query)
      options = { :action => 'opensearch',
                  :format => 'xml',
                  :search => query }
      document = self.get('/w/api.php', :query => options)
        # For a short summary:
        # document['SearchSuggestion']['Section']['Item'][0]['Description']
      # but we want the title:
      items = document['SearchSuggestion']['Section']['Item']
      if (items.is_a? Array)
        items[0]['Text']
      else
        items['Text']
      end
  end
  
  def self.art(title)
    options = { :action => 'query',
                :format => 'xml',
                :prop => 'revisions',
                :rvprop => 'content',
                :titles => title }
    document = self.get('/w/api.php', :query => options)    
    document['api']['query']['pages']['page']['revisions']['rev']
  end
  
  def self.parse(page)
    options = { :action => 'parse',
                :format => 'xml',
                :page => page }
    document = self.get('/w/api.php', :query => options)


    xml = REXML::Document.new("<xml>"+document['api']['parse']['text']+"</xml>")[0]
    
    xml.first.remove if xml.first.to_s[0..28] == "<div class='metadata topicon'"
    xml.first.remove if xml.first.to_s[0..1] == "\n"
    xml.first.remove if xml.first.to_s[0..20] == "<div class='dablink'>"
    xml.first.remove if xml.first.to_s[0..1] == "\n"
    xml.first.remove if xml.first.to_s[0..63] == "<table class='metadata plainlinks ambox ambox-content' style=''>"
    xml.first.remove if xml.first.to_s[0..1] == "\n"
    xml.first.remove if xml.first.to_s[0..25] == "<div class='thumb tright'>"
    xml.first.remove if xml.first.to_s[0..1] == "\n"
    xml.to_s.gsub(/<[a-zA-Z\/][^>]*>/,'').gsub('\n','')
  end
  
  # def self.article(title)
  #   # ?action=query&prop=revisions&titles=Rome&rvprop=content
  #   options = { :action => 'query',
  #               :format => 'xml',
  #               :prop => 'revisions',
  #               :rvprop => 'content',
  #               :titles => title }
  #   document = self.get('/w/api.php', :query => options)
  #   response = document['api']['query']['pages']['page']['revisions']['rev']
  #   # response.gsub(/\{\{(.*?)\}\}/,'').gsub(/\[\[(.*?)\]\]/,'/1').gsub(/\n/,'').gsub(/'''/,'"')
  #   self.parse(response).gsub(/&\w;/,'')
  # end
  
  def self.best(query)
    search = self.search(query)
    begin
      self.parse(search)
    # rescue
      # 'no match for "'+query+'"'
    end
  end
  
  def self.chunks(query,length)
    string = self.best(query)
    chunks = []
    while string.length > 0
      chunks.push string.slice!(0..length-1)
    end
    chunks
  end
      
end