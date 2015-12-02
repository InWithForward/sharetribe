require File.expand_path('../../services/email_service', __FILE__)

class EmailsController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_profile_settings")
  end

  def send_confirmation
    person = Person.find_by_username(params[:person_id])
    @email = Email.find_by_id_and_person_id(params[:id], person.id)
    if(@email.confirmed_at.present?)
      flash[:notice] = t("settings.account.email_already_confirmed")
      return redirect_to account_person_settings_path(person)
    end

    Email.send_confirmation(@email, @current_community)
    flash[:notice] = t("sessions.confirmation_pending.check_your_email")
    redirect_to account_person_settings_path(person)
  end

  def destroy
    person = Person.find_by_id(params[:person_id])
    email_id = params[:id]
    email = Email.find_by_id_and_person_id(email_id, person.id)

    if !email.nil? then
      list_of_allowed_emails = person.communities.collect(&:allowed_emails)
      can_delete = EmailService.can_delete_email(person.emails, email, list_of_allowed_emails)
      if can_delete[:result] == true then
        # Deleting email
        email.destroy
      else
        flash[:error] = t("layouts.notifications.can_not_delete_email")
        # Can not delete the email for some reason
      end
    else
      flash[:error] = t("layouts.notifications.user_does_not_have_email_to_delete")
      # User didn't have the email she's trying to delete
    end

    flash[:notice] = t("layouts.notifications.email_deleted")
    redirect_to account_person_settings_path
  end
end
