# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :ensure_household_exists!
  before_action :set_event, only: %i[show edit update destroy complete]

  def index
    @events = current_household.events
                               .includes(:subject)
                               .order(:scheduled_at)

    @month = if params[:month]
               Date.parse("#{params[:month]}-01")
             else
               Date.current.beginning_of_month
             end

    @month_range = @month.beginning_of_month..@month.end_of_month
    @events = @events.due_between(@month.beginning_of_month, @month.end_of_month)
  end

  def show
    Rails.logger.info '=== EventsController#show called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "@event: #{@event.inspect}"
  end

  def new
    Rails.logger.info '=== EventsController#new called ==='
    Rails.logger.info "params: #{params.inspect}"

    @event = current_household.events.build
    @event.subject = find_subject if params[:subject_type] && params[:subject_id]

    # 対象選択用のデータ
    @pets = current_household.pets.order(:name)

    Rails.logger.info '=== Rendering events/new ==='
  end

  def create
    @event = current_household.events.build(event_params)

    if @event.save
      redirect_to @event, notice: '予定を登録しました'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @event.update(event_params)
      redirect_to @event, notice: '予定を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @event.destroy
    redirect_to events_path, notice: '予定を削除しました'
  end

  def complete
    @event.complete!
    redirect_to @event, notice: '予定を完了しました'
  end

  private

  def set_event
    return if params[:id] == 'new'

    @event = current_household.events.find(params[:id])
  end

  def find_subject
    case params[:subject_type]
    when 'Pet'
      current_household.pets.find(params[:subject_id])
    end
  end

  def event_params
    params.require(:event).permit(:subject_type, :subject_id, :event_type, :title,
                                  :scheduled_at, :description)
  end
end
