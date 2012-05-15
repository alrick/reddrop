class UpdateAccesstokens < ActiveRecord::Migration
    def self.up
        change_table :accesstokens do |t|
            t.column :user, :integer
        end
    end

    def self.down
        change_table :accesstokens do |t|
            t.remove :user
        end
    end
end