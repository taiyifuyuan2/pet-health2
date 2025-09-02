class ReminderEnqueueJob < ApplicationJob
  queue_as :default

  # 毎時実行: 直近24h内で通知すべきイベントを拾う
  def perform
    now = Time.zone.now
    horizon = now + 24.hours
    Event.pending.due_between(now.to_date, horizon.to_date).find_each do |event|
      # 前日通知（remind_before_minutes）
      remind_time = event.due_at - event.remind_before_minutes.minutes
      if remind_time.between?(now - 5.minutes, now + 55.minutes)
        ReminderDeliverJob.perform_later(event.id, :pre)
      end
      # 当日朝9時通知
      if event.due_at.change(hour: 9, min: 0).between?(now - 5.minutes, now + 55.minutes)
        ReminderDeliverJob.perform_later(event.id, :day)
      end
    end
  end
end
