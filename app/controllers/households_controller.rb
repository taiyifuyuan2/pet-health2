class HouseholdsController < ApplicationController
  before_action :set_household, only: [:show, :edit, :update, :destroy]

  def show
  end

  def new
    @household = Household.new
  end

  def create
    @household = Household.new(household_params)
    
    if @household.save
      # 作成者をownerとして追加
      @household.memberships.create!(user: current_user, role: 'owner')
      redirect_to dashboard_path, notice: '世帯を作成しました'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @household.update(household_params)
      redirect_to @household, notice: '世帯情報を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @household.destroy
    redirect_to root_path, notice: '世帯を削除しました'
  end

  private

  def set_household
    @household = current_household
  end

  def household_params
    params.require(:household).permit(:name)
  end
end
