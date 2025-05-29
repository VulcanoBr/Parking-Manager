class CreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :user_type, null: false, default: 'manager'

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :user_type
  end
end
