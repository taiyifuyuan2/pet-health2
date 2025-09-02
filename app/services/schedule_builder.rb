class ScheduleBuilder
  def initialize(pet)
    @pet = pet
  end
  
  # ペットのワクチンスケジュールを自動生成
  def build_vaccination_schedule
    return [] unless @pet.birthdate.present?
    
    vaccinations = []
    
    Vaccine.includes(:vaccine_schedule_rules).each do |vaccine|
      rule = vaccine.schedule_rule
      next unless rule
      
      # 初回接種日を計算
      first_due_date = rule.next_due_date(@pet.birthdate)
      
      # 初回接種がまだの場合
      if first_due_date <= Date.current
        vaccinations << create_vaccination(vaccine, first_due_date)
        
        # 追加接種を計算
        last_date = first_due_date
        rule.booster_times.times do
          last_date = last_date + rule.repeat_every_days.days
          vaccinations << create_vaccination(vaccine, last_date)
        end
      end
    end
    
    vaccinations
  end
  
  # ペットの投薬スケジュールを自動生成
  def build_medication_schedule
    return [] unless @pet.weight_kg.present?
    
    medications = []
    
    MedicationPlan.where(applicable_now: true).each do |plan|
      next unless plan.applicable_now?
      
      # 今日から30日間の投薬スケジュールを生成
      start_date = Date.current
      end_date = start_date + 30.days
      
      current_date = start_date
      while current_date <= end_date
        medications << {
          plan: plan,
          due_date: current_date,
          dosage: plan.dosage_for_pet(@pet.weight_kg)
        }
        current_date += plan.interval_days.days
      end
    end
    
    medications
  end
  
  # 既存の予定を更新
  def update_existing_schedule
    # 期限切れのワクチンをmissedに更新
    @pet.vaccinations.pending.where('due_on < ?', Date.current).update_all(status: 'missed')
    
    # 新しい予定を追加
    build_vaccination_schedule.each do |vaccination_data|
      next if vaccination_exists?(vaccination_data)
      
      @pet.vaccinations.create!(
        vaccine: vaccination_data[:vaccine],
        due_on: vaccination_data[:due_date],
        status: 'pending'
      )
    end
  end
  
  private
  
  def create_vaccination(vaccine, due_date)
    {
      vaccine: vaccine,
      due_date: due_date
    }
  end
  
  def vaccination_exists?(vaccination_data)
    @pet.vaccinations.exists?(
      vaccine: vaccination_data[:vaccine],
      due_on: vaccination_data[:due_date]
    )
  end
end
