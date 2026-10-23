class RegistrationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.expect(user: [ :email_address, :password, :password_confirmation ]))

    if @user.save
      ConfirmationsMailer.confirm(@user).deliver_later
      redirect_to new_session_path, notice: "Check your email for a link to confirm your account."
    else
      render :new, status: :unprocessable_entity
    end
  end
end
