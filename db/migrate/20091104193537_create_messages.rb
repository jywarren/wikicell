class CreateMessages < ActiveRecord::Migration
  def self.up
    create_table :messages do |t|
      t.string :name
      t.string :number
      t.text :text
      t.string :message_type
      t.string :status
      t.timestamps
    end
  end

  def self.down
    drop_table :messages
  end
end
