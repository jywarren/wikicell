class AddQuery < ActiveRecord::Migration
  def self.up
    add_column :messages, :query, :string, :default => ''
  end

  def self.down
    remove_column :query
  end
end
