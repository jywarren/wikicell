class AddMessageId < ActiveRecord::Migration
  def self.up
	add_column :messages, :sms_id, :integer, :default => 0
  end

  def self.down
	remove_column :messages, :sms_id
  end
end
