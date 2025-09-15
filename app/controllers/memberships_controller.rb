# frozen_string_literal: true

class MembershipsController < ApplicationController
  before_action :set_household
  before_action :set_membership, only: %i[update destroy]

  def index
    @memberships = @household.memberships.includes(:user).order(:created_at)
    @invitation = @household.invitations.build if @household.respond_to?(:invitations)
  end

  def create
    # 招待を受け入れたユーザーを世帯に追加
    @membership = @household.memberships.build(membership_params)
    
    if @membership.save
      redirect_to household_memberships_path(@household), notice: 'メンバーを追加しました'
    else
      @memberships = @household.memberships.includes(:user).order(:created_at)
      render :index, status: :unprocessable_entity
    end
  end

  def update
    if @membership.update(membership_params)
      redirect_to household_memberships_path(@household), notice: 'メンバーの権限を更新しました'
    else
      @memberships = @household.memberships.includes(:user).order(:created_at)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    # オーナーは削除できない
    if @membership.role == 'owner'
      redirect_to household_memberships_path(@household), alert: 'オーナーは削除できません'
      return
    end

    @membership.destroy
    redirect_to household_memberships_path(@household), notice: 'メンバーを削除しました'
  end

  private

  def set_household
    @household = current_household
    redirect_to new_household_path, alert: '世帯が見つかりません' unless @household
  end

  def set_membership
    @membership = @household.memberships.find(params[:id])
  end

  def membership_params
    params.require(:membership).permit(:user_id, :role)
  end
end
