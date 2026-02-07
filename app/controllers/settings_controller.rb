class SettingsController < ApplicationController
  def show
    @user = Current.user
    @schools = School.all
  end

  def update
    @user = Current.user

    if @user.update(user_params)
      redirect_to settings_path, notice: t("settings.saved")
    else
      @schools = School.all
      render :show, status: :unprocessable_entity
    end
  end

  private

  def user_params
    permitted = params.require(:user).permit(:school_id, selected_languages: [])
    if permitted[:selected_languages].present?
      permitted[:selected_lang] = permitted.delete(:selected_languages).reject(&:blank?).join(",")
    end
    permitted.except(:selected_languages)
  end
end
