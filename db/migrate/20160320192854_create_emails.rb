class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :from
      t.text :body
      t.string :to

      t.timestamps null: false
    end
  end
end
