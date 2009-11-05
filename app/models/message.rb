class Message < ActiveRecord::Base

	def send
		
	#    t.integer  "type"
	#    t.integer  "status"
	#    t.string   "omsisdnA",          :limit => 40
	#    t.string   "dmsisdnA",          :limit => 40
	#    t.integer  "dest_port"
	#    t.string   "content",           :limit => 1024
	#    t.datetime "dateTimeP",                         :null => false
	#    t.integer  "smscReference"
	#    t.datetime "dispatch_dateTime",                 :null => false
	#    t.integer  "form_message"
	#    t.integer  "form_id"
		
		s = Sms.new
		# s.omsisdnA = Message.phone_number
		# s.
		s.save
		
	end

end
