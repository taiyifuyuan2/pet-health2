# frozen_string_literal: true

class EventsController < ApplicationController
  before_action :set_event, only: %i[show edit update destroy complete]
  skip_before_action :ensure_household_exists!, only: %i[index new create]

  def index
    Rails.logger.info '=== EventsController#index called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "current_user: #{current_user.inspect}"

    # 世帯が存在しない場合は世帯作成ページにリダイレクト
    unless current_household
      redirect_to new_household_path, alert: '予定を表示する前に、まず世帯を作成してください。'
      return
    end

    # 月間フィルタリング
    @month = if params[:month]
               Date.parse("#{params[:month]}-01")
             else
               Date.current.beginning_of_month
             end

    @month_range = @month.beginning_of_month..@month.end_of_month

    # ステータスフィルタリング
    @status_filter = params[:status]

    # 実際のイベントデータを取得
    @events = current_household.events
                               .where(scheduled_at: @month_range)
                               .order(:scheduled_at)

    # ステータスフィルタリングを適用
    case @status_filter
    when 'overdue'
      @events = @events.where(status: 'pending').where('scheduled_at < ?', Time.current)
      @page_title = '未完了の予定'
    when 'completed'
      @events = @events.where(status: 'completed')
      @page_title = '完了した予定'
    else
      @page_title = '今月の予定'
    end

    Rails.logger.info "Loaded #{@events.count} events from household for #{@month.strftime('%Y年%m月')} with status: #{@status_filter}"
    Rails.logger.info 'Events setup completed successfully'
  rescue StandardError => e
    Rails.logger.error "Error in EventsController#index: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    @events = []
    @month = Date.current.beginning_of_month
    @month_range = @month.beginning_of_month..@month.end_of_month
    @page_title = '今月の予定'
  end

  def show
    Rails.logger.info '=== EventsController#show called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "@event: #{@event.inspect}"
  end

  def new
    Rails.logger.info '=== EventsController#new called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "current_user: #{current_user.inspect}"
    Rails.logger.info "current_household: #{current_household.inspect}"

    # 世帯がない場合は世帯作成ページにリダイレクト
    unless current_household
      redirect_to new_household_path, alert: '予定を追加する前に、まず世帯を作成してください。'
      return
    end

    @event = current_household.events.build
    @event.subject = find_subject if params[:subject_type] && params[:subject_id]

    # 対象選択用のデータ（安全に取得）
    begin
      @pets = current_household.pets.order(:name)
      Rails.logger.info "Loaded #{@pets.count} pets"
    rescue StandardError => e
      Rails.logger.error "Error loading pets: #{e.message}"
      @pets = []
    end

    # ペットが登録されていない場合はペット登録ページにリダイレクト
    if @pets.empty?
      redirect_to new_pet_path, alert: '予定を追加する前に、まずペットを登録してください。'
      return
    end

    Rails.logger.info '=== Rendering events/new ==='
  rescue StandardError => e
    Rails.logger.error "Error in EventsController#new: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to events_path, alert: 'エラーが発生しました。'
  end

  def create
    Rails.logger.info '=== EventsController#create called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "current_user: #{current_user.inspect}"
    Rails.logger.info "current_household: #{current_household.inspect}"

    # 世帯がない場合は世帯作成ページにリダイレクト
    unless current_household
      redirect_to new_household_path, alert: '予定を追加する前に、まず世帯を作成してください。'
      return
    end

    @event = current_household.events.build(event_params)

    # 対象選択用のデータ（エラー時の再表示用、安全に取得）
    begin
      @pets = current_household.pets.order(:name)
      Rails.logger.info "Loaded #{@pets.count} pets for form re-render"
    rescue StandardError => e
      Rails.logger.error "Error loading pets in create: #{e.message}"
      @pets = []
    end

    Rails.logger.info "@event before save: #{@event.inspect}"
    Rails.logger.info "@event.errors: #{@event.errors.full_messages}" unless @event.valid?

    if @event.save
      Rails.logger.info "Event saved successfully: #{@event.id}"
      redirect_to @event, notice: '予定を登録しました'
    else
      Rails.logger.error "Event save failed: #{@event.errors.full_messages}"
      render :new
    end
  rescue StandardError => e
    Rails.logger.error "Error in EventsController#create: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to events_path, alert: 'エラーが発生しました。'
  end

  def edit
    Rails.logger.info '=== EventsController#edit called ==='
    Rails.logger.info "params: #{params.inspect}"
    Rails.logger.info "@event: #{@event.inspect}"

    # 対象選択用のデータ（安全に取得）
    begin
      @pets = current_household.pets.order(:name)
      Rails.logger.info "Loaded #{@pets.count} pets for edit"
    rescue StandardError => e
      Rails.logger.error "Error loading pets in edit: #{e.message}"
      @pets = []
    end
  rescue StandardError => e
    Rails.logger.error "Error in EventsController#edit: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    redirect_to events_path, alert: 'エラーが発生しました。'
  end

  def update
    Rails.logger.info '=== EventsController#update called ==='
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
