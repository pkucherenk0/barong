class ChangesInActivitiesTable < ActiveRecord::Migration[5.2]
  def change
    rename_column :activities, :user_id, :user_uid
    change_column :activities, :user_uid, :string
    add_column :activities, :admin_uid, :string, after: :user_uid
    add_column :permissions, :topic, :string, after: :path

    add_index :activities, :admin_uid
    add_index :permissions, :topic
  end
end
