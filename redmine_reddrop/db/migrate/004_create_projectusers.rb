class CreateProjectusers < ActiveRecord::Migration
  def self.up
    create_table :projectusers do |t|
      t.column :project, :integer
      t.column :accesstoken_id, :integer
    end
  end

  def self.down
    drop_table :projectusers
  end
end
