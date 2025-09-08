# frozen_string_literal: true

class AiHealthController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_household_exists!
  before_action :set_pet, only: [:advice, :question, :analysis]

  # AI健康アドバイスを取得
  def advice
    @ai_advisor = AiHealthAdvisor.new(@pet)
    @ai_advice = @ai_advisor.generate_personalized_advice

    respond_to do |format|
      format.html { render partial: 'ai_advice', locals: { advice: @ai_advice } }
      format.json { render json: @ai_advice }
    end
  end

  # 健康に関する質問にAIが回答
  def question
    question_text = params[:question]
    
    if question_text.blank?
      render json: { error: '質問を入力してください' }, status: :bad_request
      return
    end

    @ai_advisor = AiHealthAdvisor.new(@pet)
    @answer = @ai_advisor.answer_health_question(question_text)

    respond_to do |format|
      format.html { render partial: 'ai_answer', locals: { question: question_text, answer: @answer } }
      format.json { render json: { question: question_text, answer: @answer } }
    end
  end

  # ペットの健康状態をAIが分析
  def analysis
    @ai_advisor = AiHealthAdvisor.new(@pet)
    @analysis = @ai_advisor.analyze_health_condition

    respond_to do |format|
      format.html { render partial: 'ai_analysis', locals: { analysis: @analysis } }
      format.json { render json: @analysis }
    end
  end

  private

  def set_pet
    @pet = current_household.pets.find(params[:pet_id])
  end
end
