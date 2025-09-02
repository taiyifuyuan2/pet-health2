class PetsController < ApplicationController
  before_action :set_pet, only: [:show, :edit, :update, :destroy]

  def index
    @pets = current_household.pets.order(:name)
    
    respond_to do |format|
      format.html
      format.json { render json: @pets }
    end
  end

  def show
    @events = @pet.events.order(:scheduled_on, :scheduled_time)
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
    params.require(:pet).permit(:name, :species, :sex, :birthday, :notes, :profile_image)
  end
end
