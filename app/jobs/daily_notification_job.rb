class DailyNotificationJob < ApplicationJob
  queue_as :default
  
  def perform
    Rails.logger.info "Starting daily notification job at #{Time.current}"
    
    # 全てのペットに対して通知を生成
    Pet.includes(:breed, :vaccinations, :notifications).find_each do |pet|
      generate_notifications_for_pet(pet)
    end
    
    # 期限切れの通知をクリーンアップ
    cleanup_old_notifications
    
    Rails.logger.info "Daily notification job completed at #{Time.current}"
  end
  
  private
  
  def generate_notifications_for_pet(pet)
    # ワクチン通知
    generate_vaccination_notifications(pet)
    
    # 投薬通知
    generate_medication_notifications(pet)
    
    # 健康アドバイス通知
    generate_health_advice_notifications(pet)
  end
  
  def generate_vaccination_notifications(pet)
    # 今日のワクチン予定
    todays_vaccinations = pet.vaccinations.due_today.pending
    
    todays_vaccinations.each do |vaccination|
      next if notification_exists?(pet, 'vaccination', vaccination.vaccine.name)
      
      pet.notifications.create!(
        notification_type: 'vaccination',
        title: "ワクチン接種予定: #{vaccination.vaccine.name}",
        message: "#{pet.name}の#{vaccination.vaccine.name}ワクチン接種が予定されています。",
        scheduled_for: Date.current.beginning_of_day + 9.hours, # 朝9時に通知
        status: 'pending'
      )
    end
    
    # 明日のワクチン予定（リマインダー）
    tomorrows_vaccinations = pet.vaccinations.where(due_on: Date.tomorrow).pending
    
    tomorrows_vaccinations.each do |vaccination|
      next if notification_exists?(pet, 'vaccination_reminder', vaccination.vaccine.name)
      
      pet.notifications.create!(
        notification_type: 'vaccination',
        title: "ワクチン接種リマインダー: #{vaccination.vaccine.name}",
        message: "明日、#{pet.name}の#{vaccination.vaccine.name}ワクチン接種が予定されています。",
        scheduled_for: Date.current.beginning_of_day + 18.hours, # 夕方6時に通知
        status: 'pending'
      )
    end
  end
  
  def generate_medication_notifications(pet)
    return unless pet.weight_kg.present?
    
    # 今日の投薬予定
    todays_medications = get_todays_medications(pet)
    
    todays_medications.each do |medication|
      next if notification_exists?(pet, 'medication', medication[:plan].name)
      
      pet.notifications.create!(
        notification_type: 'medication',
        title: "投薬予定: #{medication[:plan].name}",
        message: "#{pet.name}の#{medication[:plan].name}投薬が予定されています。投薬量: #{medication[:dosage]}mg",
        scheduled_for: Date.current.beginning_of_day + 8.hours, # 朝8時に通知
        status: 'pending'
      )
    end
  end
  
  def generate_health_advice_notifications(pet)
    advisor = HealthAdvisor.new(pet)
    todays_advice = advisor.get_todays_advice
    
    todays_advice.each do |advice|
      next if notification_exists?(pet, 'health_advice', advice[:title])
      
      pet.notifications.create!(
        notification_type: 'health_advice',
        title: "健康アドバイス: #{advice[:title]}",
        message: advice[:message],
        scheduled_for: Date.current.beginning_of_day + 10.hours, # 朝10時に通知
        status: 'pending'
      )
    end
  end
  
  def get_todays_medications(pet)
    return [] unless pet.weight_kg.present?
    
    medications = []
    
    MedicationPlan.where(applicable_now: true).each do |plan|
      next unless plan.applicable_now?
      
      # 今日が投薬日かチェック
      days_since_start = (Date.current - Date.current.beginning_of_month).to_i
      if days_since_start % plan.interval_days == 0
        medications << {
          plan: plan,
          dosage: plan.dosage_for_pet(pet.weight_kg)
        }
      end
    end
    
    medications
  end
  
  def notification_exists?(pet, type, identifier)
    pet.notifications.exists?(
      notification_type: type,
      title: /#{identifier}/,
      scheduled_for: Date.current.beginning_of_day..Date.current.end_of_day
    )
  end
  
  def cleanup_old_notifications
    # 7日以上前の既読通知を削除
    Notification.where(
      status: 'read',
      scheduled_for: ...7.days.ago
    ).delete_all
    
    # 30日以上前の送信済み通知を削除
    Notification.where(
      status: 'sent',
      scheduled_for: ...30.days.ago
    ).delete_all
  end
end
