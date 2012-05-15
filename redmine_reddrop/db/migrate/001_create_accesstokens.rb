class CreateAccesstokens < ActiveRecord::Migration
  def self.up
    create_table :accesstokens do |t|
      t.column :email, :string
      t.column :value, :string
    end
  end

  def self.down
    drop_table :accesstokens
  end
end
