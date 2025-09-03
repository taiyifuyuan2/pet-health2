class WalkLogsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet
  before_action :set_walk_log, only: [:show, :edit, :update, :destroy]

  def index
    @walk_logs = @pet.walk_logs.recent
    @weekly_total_distance = WalkLog.total_distance(@pet, :this_week)
    @weekly_total_duration = WalkLog.total_duration(@pet, :this_week)
    @monthly_total_distance = WalkLog.total_distance(@pet, :this_month)
    @monthly_total_duration = WalkLog.total_duration(@pet, :this_month)
    @average_distance = WalkLog.average_distance(@pet, :this_week)
    @average_duration = WalkLog.average_duration(@pet, :this_week)
  end

  def show
  end

  def new
    @walk_log = @pet.walk_logs.build(date: Date.current)
  end

  def create
    @walk_log = @pet.walk_logs.build(walk_log_params)

    if @walk_log.save
      redirect_to pet_walk_logs_path(@pet), notice: '散歩ログを登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @walk_log.update(walk_log_params)
      redirect_to pet_walk_logs_path(@pet), notice: '散歩ログを更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @walk_log.destroy
    redirect_to pet_walk_logs_path(@pet), notice: '散歩ログを削除しました。'
  end

  private

  def set_pet
    @pet = current_household.pets.find(params[:pet_id])
  end

  def set_walk_log
    @walk_log = @pet.walk_logs.find(params[:id])
  end

  def walk_log_params
    params.require(:walk_log).permit(:date, :distance_km, :duration_minutes, :note)
  end
end