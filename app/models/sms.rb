class Sms < ActiveRecord::Base
  set_table_name "frontline_messages"
  set_inheritance_column :ruby_type
  set_primary_key "tid"
  
	  # t.integer  "type"
	  # t.integer  "status"
	  # t.string   "omsisdnA",          :limit => 40
	  # t.string   "dmsisdnA",          :limit => 40
	  # t.integer  "dest_port"
	  # t.string   "content",           :limit => 1024
	  # t.datetime "dateTimeP",                         :null => false
	  # t.integer  "smscReference"
	  # t.datetime "dispatch_dateTime",                 :null => false
	  # t.integer  "form_message"
	  # t.integer  "form_id"
		
    # 1
    # 2
    # 5
    # 355634007625285
    # 7184966293
    # 0
    # Testing
    # 2009-05-11 13:25:13
    # 0
    # 2009-05-11 13:24:34
    # 0
    # -1
    
    def self.new_outgoing(text,number)
      sms = self.new
      sms.type = 2
      sms.status = 4
      sms.dest_port = 0
      sms.omsisdnA = '* N/A *'
      sms.dmsisdnA = number
      sms.content = text
      sms.dispatch_dateTime = DateTime.now
      sms.dateTimeP = DateTime.now
      sms.form_message = 0
      sms.form_id = -1
      sms.save
    end
        
end
