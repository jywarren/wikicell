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
	puts document
        # For a short summary:
        # document['SearchSuggestion']['Section']['Item'][0]['Description']
      # but we want the title:
      if document['SearchSuggestion'] && document['SearchSuggestion']['Section'] && document['SearchSuggestion']['Section']['Item']
	      items = document['SearchSuggestion']['Section']['Item']
	      if (items.is_a? Array)
	        items[0]['Text']
	      else
	        items['Text']
	      end
      else
	false
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
  
  def self.clean_nodes(node)
    	node.remove if node.to_s[0..28] == "<div class='metadata topicon'"
    	node.remove if node.to_s[0..20] == "<div class='dablink'>"
	node.remove if node.to_s[0..63] == "<table class='metadata plainlinks ambox ambox-content' style=''>"
    	node.remove if node.to_s[0..1] == "\n"
    	node.remove if node.to_s[0..25] == "<div class='thumb tright'>"
  end

  def self.parse(page)
    options = { :action => 'parse',
                :format => 'xml',
                :page => page }
    document = self.get('/w/api.php', :query => options)


    xml = REXML::Document.new("<xml>"+document['api']['parse']['text']+"</xml>")[0]
    
    xml.each do |node|
	Wikipedia.clean_nodes(node)
	if node.is_a? REXML::Element
		node.each do |subnode|
			Wikipedia.clean_nodes(node)
		end
	end
    end

    response = xml.to_s.strip.gsub(/<[a-zA-Z\/][^>]*>/,'').gsub('\n','')
    response
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
    puts 'best match for "'+query+'"'
    search = self.search(query)
    begin
    if search
      self.parse(search)
    else
	false
    end
    # rescue
      # 'no match for "'+query+'"'
    end
  end
  
  def self.chunks(query,length)
    string = self.best(query)
    chunks = []
    if string
    while string.length > 0
      chunks.push string.slice!(0..length-1)
    end
    chunks
    else
	false
    end
  end
      
end
