class CreateHealthRiskRules < ActiveRecord::Migration[7.1]
  def change
    create_table :health_risk_rules do |t|
      t.jsonb :trigger_conditions
      t.text :message
      t.integer :priority

      t.timestamps
    end
  end
end
