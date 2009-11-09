#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"
require File.dirname(__FILE__) + "/../../lib/gsm.rb"
require File.dirname(__FILE__) + "/../../lib/cellkit.rb"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do

	# Read text messages from phone
	messages = Cellkit.messages

	# Iterate through them
	messages.each do |msg|
	  puts "#{msg.id} - #{msg.time} - #{msg.sender} - #{msg.message}"

	  m = Message.new(:number => msg.sender,:text => msg.message,:message_type => 'incoming', :status => 'received',:name => 'anonymous',:sms_id => msg.id)
	  m.save

	  msg.delete
	end

	# now fetch received messages and answer them:
	messages = Message.find(:all,:conditions => ['status = ?','received'])
    	messages.each do |message|
	
	      if message.query == 'query'
	        # initial:
	      
		article = Rails.cache.read('query:'+message.text)
		unless article
			article = Wikipedia.chunks(message.text,120)
			Rails.cache.write('query:'+message.text,article) if article
		end
	
		if article
			Cellkit.send(:number => message.number,:message => article[0]+ ' ['+(article.length).to_s+' more]')
			puts 'sent sms'
		        message.status = 'complete'
		else
		  message.status = 'failed'
		end
	      elsif message.query == 'more'
	        # asking for more
	        
	        # find last query:
	        last = Message.find :last, :conditions => ["query != ?",'more']
	        article = Wikipedia.chunks(last.text,120)
	
	        # find out how many times we've asked
	        mores = Message.find( :all, :conditions => ['created_at > ?',last.created_at]).length
		Cellkit.send(:number => message.number,:message => article[mores]+ ' ['+(article.length-mores).to_s+']')
	        message.status = 'complete'
	      end
	      message.save
      
    end
    
    puts 'Wikicell answered '+messages.length.to_s+' messages'
  
  sleep 3
end
