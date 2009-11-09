require "rubygems"
require "rubysms"

class DemoApp < SMS::App
    def incoming(msg)
      msg.respond("Wow, that was easy!")
    end
end

DemoApp.serve!

