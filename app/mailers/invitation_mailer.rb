# frozen_string_literal: true

class InvitationMailer < ApplicationMailer
  def invite_user(invitation)
    @invitation = invitation
    @household = invitation.household
    @invited_by = invitation.invited_by
    @accept_url = accept_invitation_url(token: invitation.token)

    mail(
      to: invitation.email,
      subject: "#{@household.name}の世帯に招待されました"
    )
  end
end
