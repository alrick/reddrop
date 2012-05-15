class CreateGeneratedfolders < ActiveRecord::Migration
  def self.up
    create_table :generatedfolders do |t|
      t.column :name, :string
    end
  end

  def self.down
    drop_table :generatedfolders
  end
end
