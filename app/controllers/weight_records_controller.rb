# frozen_string_literal: true

class WeightRecordsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pet
  before_action :set_weight_record, only: %i[show edit update destroy]

  def index
    @weight_records = @pet.weight_records.recent
    @chart_data = WeightRecord.chart_data(@pet, params[:period]&.to_sym || :last_30_days)
    @latest_weight = WeightRecord.latest_weight(@pet)
    @weight_change = WeightRecord.weight_change(@pet, 30)
  end

  def show; end

  def new
    @weight_record = @pet.weight_records.build(date: Date.current)
  end

  def create
    @weight_record = @pet.weight_records.build(weight_record_params)

    if @weight_record.save
      redirect_to pet_weight_records_path(@pet), notice: '体重記録を登録しました。'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @weight_record.update(weight_record_params)
      redirect_to pet_weight_records_path(@pet), notice: '体重記録を更新しました。'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @weight_record.destroy
    redirect_to pet_weight_records_path(@pet), notice: '体重記録を削除しました。'
  end

  private

  def set_pet
    @pet = current_household.pets.find(params[:pet_id])
  end

  def set_weight_record
    @weight_record = @pet.weight_records.find(params[:id])
  end

  def weight_record_params
    params.require(:weight_record).permit(:date, :weight_kg, :note)
  end
end
