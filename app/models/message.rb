class Message < ActiveRecord::Base

	def before_save
	      if self.text.downcase.strip == 'more'
	        self.query = 'more'
	      else
	        self.query = 'query'
	      end
	end
	def validate
		if Message.find :all, :conditions => {:text => self.text, :sms_id => self.sms_id}
			puts 'failed - duplicate message'
			false
		else
			puts 'imported a message'
			true
		end
	end

end
