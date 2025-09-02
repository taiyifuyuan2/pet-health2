class ReminderDeliverJob < ApplicationJob
  queue_as :mailers

  def perform(event_id, phase)
    event = Event.find(event_id)
    event.household.memberships.includes(:user).each do |membership|
      user = membership.user
      setting = user.notification_setting || NotificationSetting.new(email_enabled: true)
      if setting.email_enabled?
        EventMailer.with(user: user, event: event, phase: phase).notify.deliver_now
      end
      # PostMVP: LINE Notify / Web Push
    end
  end
end
