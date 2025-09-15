# frozen_string_literal: true

class InvitationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :accept]
  skip_before_action :ensure_household_exists!, only: [:show, :accept]
  before_action :set_household, only: [:create]

  def create
    @invitation = @household.invitations.build(invitation_params)
    @invitation.invited_by = current_user
    @invitation.token = generate_invitation_token
    @invitation.expires_at = 7.days.from_now

    if @invitation.save
      # 招待メールを送信
      InvitationMailer.invite_user(@invitation).deliver_now
      redirect_to household_memberships_path(@household), notice: '招待メールを送信しました'
    else
      @memberships = @household.memberships.includes(:user).order(:created_at)
      render 'memberships/index', status: :unprocessable_entity
    end
  end

  def show
    set_invitation
    return if performed?
    
    if @invitation.expired?
      redirect_to root_path, alert: '招待リンクの有効期限が切れています'
      return
    end

    if @invitation.accepted?
      redirect_to root_path, alert: 'この招待は既に受け入れられています'
      return
    end

    # 招待詳細ページを表示（ログイン済み・未ログイン問わず）
    render :show
  end

  def accept
    set_invitation
    return if performed?
    
    if @invitation.expired?
      redirect_to root_path, alert: '招待リンクの有効期限が切れています'
      return
    end

    if @invitation.accepted?
      redirect_to root_path, alert: 'この招待は既に受け入れられています'
      return
    end

    unless user_signed_in?
      session[:invitation_token] = @invitation.token
      redirect_to new_user_session_path, alert: '世帯に参加するにはログインが必要です'
      return
    end

    join_household(@invitation)
  end

  private

  def set_household
    @household = current_household
    redirect_to new_household_path, alert: '世帯が見つかりません' unless @household
  end

  def set_invitation
    @invitation = Invitation.active.find_by(token: params[:token])
    redirect_to root_path, alert: '無効な招待リンクです' unless @invitation
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def generate_invitation_token
    SecureRandom.urlsafe_base64(32)
  end

  def join_household(invitation)
    # 既に参加している場合はスキップ
    if current_user.households.include?(invitation.household)
      redirect_to dashboard_path, notice: '既にこの世帯のメンバーです'
      return
    end

    # 世帯に参加
    membership = invitation.household.memberships.create!(
      user: current_user,
      role: invitation.role
    )

    # 招待を無効化
    invitation.update!(accepted_at: Time.current)

    # セッションに世帯IDを保存
    session[:household_id] = invitation.household.id
    
    # 招待トークンをセッションから削除
    session.delete(:invitation_token)

    redirect_to dashboard_path, notice: '世帯に参加しました'
  end
end
