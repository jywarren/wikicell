class OperatorController < ApplicationController

  def fetch
    # get incoming:
    sms = Sms.find(:all, :conditions => {:type => 1, :status => 1})
    sms.each do |s|
      Message.new_from_sms(s)
    end
    render :text => 'got '+sms.length.to_s+' messages'
  end

  def answer
    messages = Message.find(:all)
    messages.each do |message|

      if message.query == 'query'
        # initial:
      
        article = Wikipedia.chunks(message.text,160)

        Sms.new_outgoing(article[0],message.number)
      
      elsif message.query == 'more'
        # asking for more
        
        # find last query:
        last = Message.find :last, :conditions => ["query != ?",'more']
        article = Wikipedia.chunks(last.text,160)

        # find out how many times we've asked
        mores = Message.find :all, :conditions => ['created_at > ?',last.created_at]
        
        Sms.new_outgoing(article[mores.length],message.number)

      end
      
    end
    
    render :text => 'answered '+messages.length.to_s+' messages'
  end

end
