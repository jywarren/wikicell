class Cellkit
	
	DEVICES_PATH = '/dev/'

	def initialize
		self.setup unless File.exist?("#{RAILS_ROOT}/config/gsm.yml")
		puts 'GSM device found at '+ self.port.to_s
	end

	def self.setup
		puts 'setting up Cellkit'
		if File.exist?("#{RAILS_ROOT}/config/gsm.yml")
			config = YAML.load_file "#{RAILS_ROOT}/config/gsm.yml"
		else
			config = {'device' => {'port' => 'default'}}
		end
		config['device']['port'] = DEVICES_PATH+self.devices.first
		puts config['device']['port']
		File.open("#{RAILS_ROOT}/config/gsm.yml", 'w') { |f| YAML.dump(config, f) }
	end

	def self.devices
		Dir.chdir(DEVICES_PATH)
		ports = Dir.glob('ttyS*').to_a + Dir.glob('ttyACM*').to_a
		puts ports
		devices = []
		ports.each do |port|
			begin
				p = GSM.new(:port => DEVICES_PATH+port)
				puts p
				devices << port
			rescue
				puts port+' is not a serial port'
			end
		end
		devices
	end

	def self.port
		YAML.load_file("#{RAILS_ROOT}/config/gsm.yml")['device']['port']
	end

	def self.activate
		GSM.new(:port => self.port)
	end

	def self.messages
		gsm = self.activate
		gsm.messages
	end

	def self.send(options = {})
		gsm = self.activate
		gsm.send_sms(options)
	end

end
