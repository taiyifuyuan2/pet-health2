# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy complete]
  skip_before_action :ensure_household_exists!, only: [:index]

  def index
    begin
      Rails.logger.info '=== EventsController#index called ==='
      Rails.logger.info "params: #{params.inspect}"
      Rails.logger.info "current_user: #{current_user.inspect}"
      
      # 完全にシンプルな実装
      @events = []
      @month = Date.current.beginning_of_month
      @month_range = @month.beginning_of_month..@month.end_of_month
      
      Rails.logger.info "Basic setup completed successfully"
      
    rescue => e
      Rails.logger.error "Error in EventsController#index: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      @events = []
      @month = Date.current.beginning_of_month
      @month_range = @month.beginning_of_month..@month.end_of_month
    end
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
    
    # ペットが登録されていない場合はペット登録ページにリダイレクト
    if @pets.empty?
      redirect_to new_pet_path, alert: '予定を追加する前に、まずペットを登録してください。'
      return
    end

    Rails.logger.info '=== Rendering events/new ==='
  end

  def create
    Rails.logger.info "=== EventsController#create called ==="
    Rails.logger.info "params: #{params.inspect}"
    
    @event = current_household.events.build(event_params)
    
    # 対象選択用のデータ（エラー時の再表示用）
    @pets = current_household.pets.order(:name)

    Rails.logger.info "@event before save: #{@event.inspect}"
    Rails.logger.info "@event.errors: #{@event.errors.full_messages}" unless @event.valid?

    if @event.save
      Rails.logger.info "Event saved successfully: #{@event.id}"
      redirect_to @event, notice: '予定を登録しました'
    else
      Rails.logger.error "Event save failed: #{@event.errors.full_messages}"
      render :new
    end
  end

  def edit
    Rails.logger.info '=== EventsController#edit called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "@event: #{@event.inspect}"
    
    # 対象選択用のデータ
    @pets = current_household.pets.order(:name)
  end

  def update
    Rails.logger.info "=== EventsController#update called ==="
    Rails.logger.info "params: #{params.inspect}"
    
    # 対象選択用のデータ（エラー時の再表示用）
    @pets = current_household.pets.order(:name)
    
    if @event.update(event_params)
      Rails.logger.info "Event updated successfully: #{@event.id}"
      redirect_to @event, notice: '予定を更新しました'
    else
      Rails.logger.error "Event update failed: #{@event.errors.full_messages}"
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
