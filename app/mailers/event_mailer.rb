class EventMailer < ApplicationMailer
  def notify
    @user = params[:user]
    @event = params[:event]
    @phase = params[:phase] # :pre or :day
    
    subject = case @phase
    when :pre
      "【お知らせ】#{@event.title}（#{@event.scheduled_on.strftime('%m/%d')}）"
    when :day
      "【本日】#{@event.title}（#{@event.scheduled_on.strftime('%m/%d')}）"
    else
      "【お知らせ】#{@event.title}（#{@event.scheduled_on.strftime('%m/%d')}）"
    end

    mail(to: @user.email, subject: subject)
  end
end
