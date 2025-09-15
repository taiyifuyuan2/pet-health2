# frozen_string_literal: true

class AiHealthController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_household_exists!
  before_action :set_pet, only: [:question]

  # 健康に関する質問にAIが回答
  def question
    question_text = params[:question]

    Rails.logger.info "AI Question received: #{question_text}"

    if question_text.blank?
      Rails.logger.warn 'Empty question received'
      render json: { error: '質問を入力してください' }, status: :bad_request
      return
    end

    begin
      @ai_advisor = AiHealthAdvisor.new(@pet)
      @answer = @ai_advisor.answer_health_question(question_text)

      Rails.logger.info "AI Answer generated: #{@answer[0..100]}..."

      respond_to do |format|
        format.html { render partial: 'ai_health/ai_answer', locals: { question: question_text, answer: @answer } }
        format.json { render json: { question: question_text, answer: @answer } }
      end
    rescue StandardError => e
      Rails.logger.error "AI Question Error: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")

      error_message = '申し訳ございません。AIサービスでエラーが発生しました。'
      respond_to do |format|
        format.html do
          render partial: 'ai_health/ai_answer', locals: { question: question_text, answer: error_message }
        end
        format.json { render json: { error: error_message }, status: :internal_server_error }
      end
    end
  end

  private

  def set_pet
    @pet = current_household.pets.find(params[:pet_id])
  end
end
