class PetsController < ApplicationController
  before_action :ensure_household_exists!
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @pets = current_household.pets.order(:name)
    
    respond_to do |format|
      format.html
      format.json { render json: @pets }
    end
  end

  def show
    @events = @pet.events.order(:scheduled_at)
    @vaccinations = @pet.vaccinations.includes(:vaccine).order(:due_on)
    @notifications = @pet.notifications.order(:scheduled_for)
    
    # 健康アドバイスを取得
    @health_advisor = HealthAdvisor.new(@pet)
    @todays_advice = @health_advisor.get_todays_advice
    @weekly_advice = @health_advisor.get_weekly_advice
    
    # 今日の予定を取得
    @todays_schedule = @pet.todays_schedule
    @this_weeks_schedule = @pet.this_weeks_schedule
  end

  def new
    @pet = current_household.pets.build
  end

  def create
    @pet = current_household.pets.build(pet_params)
    
    if @pet.save
      redirect_to @pet, notice: 'ペットを登録しました'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @pet.update(pet_params)
      redirect_to @pet, notice: 'ペット情報を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @pet.destroy
    redirect_to pets_path, notice: 'ペットを削除しました'
  end

  private

  def set_pet
    @pet = current_household.pets.find(params[:id])
  end

  def pet_params
    params.require(:pet).permit(:name, :species, :sex, :birthdate, :notes, :profile_image, :breed_id, :weight_kg)
  end
end
