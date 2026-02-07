class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "잠시 후 다시 시도해주세요." }

  def new
    @user = User.new
    @schools = School.order(:name)
  end

  def create
    @user = User.new(registration_params)

    if params[:password_confirmation].present? && params[:password_confirmation] != params.dig(:user, :password)
      @user.errors.add(:password_confirmation, :confirmation, attribute: "Password")
      @schools = School.order(:name)
      return render :new, status: :unprocessable_entity
    end

    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: t("registrations.success")
    else
      @schools = School.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    permitted = params.require(:user).permit(:email_address, :password, :school_id, selected_languages: [])
    if permitted[:selected_languages].present?
      permitted[:selected_lang] = permitted.delete(:selected_languages).reject(&:blank?).join(",")
    else
      permitted[:selected_lang] = "ko"
    end
    permitted.except(:selected_languages)
  end
end
