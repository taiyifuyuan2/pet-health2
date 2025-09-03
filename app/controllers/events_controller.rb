# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy complete]

  def index
    begin
      Rails.logger.info '=== EventsController#index called ==='
      Rails.logger.info "params: #{params.inspect}"
      
      Rails.logger.info "current_household: #{current_household.inspect}"
      
      @events = current_household.events
                                 .includes(:subject)
                                 .order(:scheduled_at)

      Rails.logger.info "Initial events count: #{@events.count}"

      @month = if params[:month]
                 Date.parse("#{params[:month]}-01")
               else
                 Date.current.beginning_of_month
               end

      Rails.logger.info "Selected month: #{@month}"

      @month_range = @month.beginning_of_month..@month.end_of_month
      @events = @events.due_between(@month.beginning_of_month, @month.end_of_month)
      
      Rails.logger.info "Filtered events count: #{@events.count}"
      
      # 各イベントの仮想属性を設定
      @events.each_with_index do |event, index|
        Rails.logger.info "Processing event #{index + 1}: #{event.id}"
        begin
          event.kind = event.event_type if event.event_type.present?
          event.note = event.description if event.description.present?
          event.scheduled_on = event.scheduled_at.to_date if event.scheduled_at.present?
          event.scheduled_time = event.scheduled_at.to_time if event.scheduled_at.present?
          Rails.logger.info "Event #{index + 1} processed successfully"
        rescue => e
          Rails.logger.error "Error processing event #{index + 1}: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
      
      Rails.logger.info "Successfully loaded #{@events.count} events"
    rescue => e
      Rails.logger.error "Error in EventsController#index: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      raise e
    end
  end

  def show
    Rails.logger.info '=== EventsController#show called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "@event: #{@event.inspect}"
    
    # 既存のデータを新しいフィールドにマッピング（表示用）
    @event.kind = @event.event_type if @event.event_type.present?
    @event.note = @event.description if @event.description.present?
    @event.scheduled_on = @event.scheduled_at.to_date if @event.scheduled_at.present?
    @event.scheduled_time = @event.scheduled_at.to_time if @event.scheduled_at.present?
    
    Rails.logger.info "@event after mapping: #{@event.inspect}"
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
    
    # scheduled_onとscheduled_timeを組み合わせてscheduled_atを作成
    if @event.scheduled_on.present?
      if @event.scheduled_time.present?
        scheduled_time = @event.scheduled_time
      else
        scheduled_time = Time.parse("12:00")
      end
      
      @event.scheduled_at = DateTime.new(
        @event.scheduled_on.year,
        @event.scheduled_on.month,
        @event.scheduled_on.day,
        scheduled_time.hour,
        scheduled_time.min
      )
    end
    
    # kindをevent_typeにマッピング
    @event.event_type = @event.kind if @event.kind.present?
    
    # noteをdescriptionにマッピング
    @event.description = @event.note if @event.note.present?

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
    
    # 既存のデータを新しいフィールドにマッピング
    @event.kind = @event.event_type if @event.event_type.present?
    @event.note = @event.description if @event.description.present?
    @event.scheduled_on = @event.scheduled_at.to_date if @event.scheduled_at.present?
    @event.scheduled_time = @event.scheduled_at.to_time if @event.scheduled_at.present?
    
    Rails.logger.info "@event after mapping: #{@event.inspect}"
  end

  def update
    Rails.logger.info "=== EventsController#update called ==="
    Rails.logger.info "params: #{params.inspect}"
    
    # 対象選択用のデータ（エラー時の再表示用）
    @pets = current_household.pets.order(:name)
    
    # パラメータを更新
    update_params = event_params.dup
    
    # scheduled_onとscheduled_timeを組み合わせてscheduled_atを作成
    if update_params[:scheduled_on].present?
      if update_params[:scheduled_time].present?
        scheduled_time = Time.parse(update_params[:scheduled_time])
      else
        scheduled_time = Time.parse("12:00")
      end
      
      scheduled_date = Date.parse(update_params[:scheduled_on])
      update_params[:scheduled_at] = DateTime.new(
        scheduled_date.year,
        scheduled_date.month,
        scheduled_date.day,
        scheduled_time.hour,
        scheduled_time.min
      )
    end
    
    # kindをevent_typeにマッピング
    if update_params[:kind].present?
      update_params[:event_type] = update_params[:kind]
    end
    
    # noteをdescriptionにマッピング
    if update_params[:note].present?
      update_params[:description] = update_params[:note]
    end
    
    Rails.logger.info "update_params: #{update_params.inspect}"
    
    if @event.update(update_params)
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
    params.require(:event).permit(:subject_type, :subject_id, :kind, :title,
                                  :scheduled_on, :scheduled_time, :remind_before_minutes, :note)
  end
end
