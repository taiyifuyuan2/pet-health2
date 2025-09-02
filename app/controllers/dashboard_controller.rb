class DashboardController < ApplicationController
  def show
    @household = current_household
    return redirect_to new_household_path unless @household

    @today = Date.current
    @this_month = @today.beginning_of_month..@today.end_of_month
    
    # 今月の予定
    @upcoming_events = @household.events
                                 .due_between(@today, @this_month.end)
                                 .pending
                                 .order(:scheduled_on, :scheduled_time)
                                 .limit(10)
    
    # 未完了の予定
    @overdue_events = @household.events
                                .due_between(@this_month.begin, @today - 1.day)
                                .pending
                                .order(:scheduled_on)
    
    # 最近完了した予定
    @recent_completed = @household.events
                                  .completed
                                  .where(completed_at: 7.days.ago..Time.current)
                                  .order(completed_at: :desc)
                                  .limit(5)
  end
end
