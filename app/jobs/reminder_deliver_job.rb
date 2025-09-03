# frozen_string_literal: true

class ReminderDeliverJob < ApplicationJob
  queue_as :mailers

  def perform(event_id, phase)
    event = Event.find(event_id)
    event.household.memberships.includes(:user).each do |membership|
      user = membership.user
      setting = user.notification_setting || NotificationSetting.new(email_enabled: true)
      EventMailer.with(user: user, event: event, phase: phase).notify.deliver_now if setting.email_enabled?
      # PostMVP: LINE Notify / Web Push
    end
  end
end
