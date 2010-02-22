# based on:
# http://snippets.dzone.com/posts/show/3647
# by Peter Cooperx http://www.petercooper.co.uk/

require 'serialport'
require 'time'

class GSM
  
#   SMSC = "+447785016005"  # SMSC for Vodafone UK - change for other networks
   SMSC = "+12063130004" # SMSC for T-mobile US
#   SMSC = "+51195599000" # SMSC for Movistar Peru
#   SMSC numbers: http://www.weethet.nl/english/gsm_smscnumbers.php
#   also, not as good: http://www.ozeki.hu/index.phtml?ow_page_number=458

  def initialize(options = {})
    @port = SerialPort.new(options[:port] || 3, options[:baud] || 38400, options[:bits] || 8, options[:stop] || 1, SerialPort::NONE)
    @debug = options[:debug]
    cmd("AT")
    # Set to text mode
    cmd("AT+CMGF=1")
    # Set SMSC number
    cmd("AT+CSCA=\"#{SMSC}\"")    
  end
  
  def close
    @port.close
  end
  
  def cmd(cmd)
    sleep 3
    @port.write(cmd + "\r")
    wait
  end
  
  def wait
    buffer = ''
    while IO.select([@port], [], [], 0.25)
      chr = @port.getc.chr;
      print chr if @debug == true
      buffer += chr
    end
    buffer
  end

  def send_sms(options)
    cmd("AT+CMGS=\"#{options[:number]}\"")
    cmd("#{options[:message][0..140]}#{26.chr}\r\r")
    sleep 3
    wait
    cmd("AT")
  end
  
  class SMS
    attr_accessor :id, :sender, :message, :connection
    attr_writer :time
    
    def initialize(params)
        @id = params[:id]; @sender = params[:sender]; @time = params[:time]; @message = params[:message]; @connection = params[:connection]
    end
    
    def delete
      @connection.cmd("AT+CMGD=#{@id}")
    end
    
    def time
      # This MAY need to be changed for non-UK situations, I'm not sure
      # how standardized SMS timestamps are..
      Time.parse(@time.sub(/(\d+)\D+(\d+)\D+(\d+)/, '\2/\3/20\1'))
    end
  end

  def messages
    sms = cmd("AT+CMGL=\"ALL\"")
    # Ugly, ugly, ugly!
    msgs = sms.scan(/\+CMGL\:\s*?(\d+)\,.*?\,\"(.+?)\"\,.*?\,\"(.+?)\".*?\n(.*)/)
    return nil unless msgs
    msgs.collect!{ |m| GSM::SMS.new(:connection => self, :id => m[0], :sender => m[1], :time => m[2], :message => m[3].chomp) } rescue nil
  end

  # http://www.developershome.com/sms/cmgdCommand.asp

  #+CMGD=index[,flag]
  # In the above line, index is an integer specifying the location of the SMS message to be deleted from the message storage area by the +CMGD AT command, and flag is an integer specifying whether to delete SMS messages according to their message status. The SMS specification has defined these flag values: 0, 1, 2, 3 and 4.
#      0. Meaning: Delete only the SMS message stored at the location index from the message storage area. This is the default value.
#      1. Meaning: Ignore the value of index and delete all SMS messages whose status is "received read" from the message storage area.
#      2. Meaning: Ignore the value of index and delete all SMS messages whose status is "received read" or "stored sent" from the message storage area.
#      3. Meaning: Ignore the value of index and delete all SMS messages whose status is "received read", "stored unsent" or "stored sent" from the message storage area.
#      4. Meaning: Ignore the value of index and delete all SMS messages from the message storage area.

  def clear_all
    @connection.cmd("AT+CMGD=1,4")
  end

end
