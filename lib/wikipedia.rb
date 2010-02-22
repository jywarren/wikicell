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
  
  def self.article(title)
    puts "GETTING "+title
    options = { :action => 'query',
                :format => 'xml',
                :prop => 'revisions',
                :rvprop => 'content',
                :titles => title }
    document = self.get('/w/api.php', :query => options)    
    document['api']['query']['pages']['page']['revisions']['rev']
  end
  
  def self.parse(wikitext)
    options = { :action => 'parse',
                :text => wikitext,
                :format => 'xml' }
    document = self.get('/w/api.php', :query => options)
    document['api']['parse']['text']
  end

  # remove unwanted markup, captions
  def self.clean_nodes(nodes)
    clean_nodes = []
    nodes.each do |node|
      clean = true
      clean = false if node.to_s[0..28] == "<div class='metadata topicon'"
      clean = false if node.to_s[0..19] == "<div class='dablink'"
      clean = false if node.to_s[0..63] == "<table class='metadata plainlinks ambox ambox-content' style=''>"
      clean = false if node.to_s[0..1] == "\n"
      clean = false if node.to_s[0..24] == "<div class='thumb tright'"
      clean = false if node.to_s[0..26] == "<table id='toc' class='toc'"
      clean = false if node.to_s[0..30] == "<p><br />\n<strong class='error"
      clean_nodes << node.to_s if clean
    end
    clean_nodes
  end

  def self.fetch(page)
    document = self.article(page)

    document = self.parse(document[0..2000])

    nodes = REXML::Document.new("<xml>"+document+"</xml>")[0][0..20]

    response = Wikipedia.clean_nodes(nodes)
	
    response = response.join.strip.gsub('&lt;','<').gsub('&gt;','>').gsub(/<[a-zA-Z\/][^>]*>/,'')
    response = response.gsub(/\n/,' ')
    response
  end
  
  def self.best(query)
    puts 'best match for "'+query+'"'
    search = self.search(query)
    begin
    if search
      self.fetch(search)
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
    puts chunks
    chunks
    else
	false
    end
  end
      
end
