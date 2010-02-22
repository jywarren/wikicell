class OperatorController < ApplicationController

  def devices
	render :text => Cellkit.devices.join(',')
  end

  def answered
	messages = []
	Message.find(:all,:conditions => {:status => 'complete'}).map do |msg|
		messages << msg.text
	end
	render :text => messages.join('<br />')
  end

end
