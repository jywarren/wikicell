class Message < ActiveRecord::Base

	def send_sms
    Sms.new_outgoing(self.text,self.number) if self.message_type == 'outgoing'
	end
	
	def self.new_from_sms(sms)
	  m = Message.new
      m.message_type = 'incoming'
      m.status = 'received'
      m.number = sms.omsisdnA
      m.name = 'anonymous'
      m.text = sms.content
      m.created_at = sms.dateTimeP

      if m.text == 'more'
        m.query = 'more'
      else
        m.query = 'query'
      end
      
    m.save
  end

end
