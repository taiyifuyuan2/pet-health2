# frozen_string_literal: true

class DashboardController < ApplicationController
  before_action :ensure_household_exists!

  def show
    @household = current_household
    return redirect_to new_household_path unless @household

    # 日本時間基準で計算
    jst_time = Time.current.in_time_zone('Asia/Tokyo')
    @today = jst_time.to_date
    @this_month = @today.beginning_of_month..@today.end_of_month

    # デバッグ用ログ（本番環境でも確認可能）
    Rails.logger.info "Dashboard Debug - JST Time: #{jst_time}"
    Rails.logger.info "Dashboard Debug - Today: #{@today}"
    Rails.logger.info "Dashboard Debug - This Month: #{@this_month.begin} to #{@this_month.end}"

    # 今月の予定
    @upcoming_events = @household.events
                                 .due_between(@today, @this_month.end)
                                 .pending
                                 .order(:scheduled_at)
                                 .limit(10)

    # デバッグ用ログ
    Rails.logger.info "Dashboard Debug - Upcoming Events Count: #{@upcoming_events.count}"
    Rails.logger.info "Dashboard Debug - All Events in Month: #{@household.events.due_between(@this_month.begin, @this_month.end).count}"

    # 未完了の予定
    @overdue_events = @household.events
                                .due_between(@this_month.begin, @today - 1.day)
                                .pending
                                .order(:scheduled_at)

    # 最近完了した予定
    @recent_completed = @household.events
                                  .completed
                                  .where(completed_at: 7.days.ago..Time.current)
                                  .order(completed_at: :desc)
                                  .limit(5)
  end
end
