class AddFieldsToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :kind, :string
    add_column :events, :scheduled_on, :date
    add_column :events, :scheduled_time, :time
    add_column :events, :remind_before_minutes, :integer
    add_column :events, :note, :text
  end
end
