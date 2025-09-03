# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update destroy]

  def index
    @contacts = current_household.contacts.order(:name)

    respond_to do |format|
      format.html
      format.json { render json: @contacts }
    end
  end

  def show
    @events = @contact.events.order(:scheduled_on, :scheduled_time)
  end

  def new
    @contact = current_household.contacts.build
  end

  def create
    @contact = current_household.contacts.build(contact_params)

    if @contact.save
      redirect_to @contact, notice: '連絡先を登録しました'
    else
      render :new
    end
  end

  def edit; end

  def update
    if @contact.update(contact_params)
      redirect_to @contact, notice: '連絡先情報を更新しました'
    else
      render :edit
    end
  end

  def destroy
    @contact.destroy
    redirect_to contacts_path, notice: '連絡先を削除しました'
  end

  private

  def set_contact
    @contact = current_household.contacts.find(params[:id])
  end

  def contact_params
    params.require(:contact).permit(:name, :birthday, :relation, :notes)
  end
end
