class ConfirmationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_confirmation_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])
    ConfirmationsMailer.confirm(user).deliver_later if user && !user.confirmed?

    redirect_to new_session_path, notice: "If that account still needs confirming, we've sent a new link."
  end

  def show
    if user = User.find_by_token_for(:email_confirmation, params[:token])
      user.confirm!
      start_new_session_for user
      redirect_to root_path, notice: "Your email address is confirmed. Welcome!"
    else
      redirect_to new_confirmation_path, alert: "That confirmation link is invalid or has expired."
    end
  end
end
