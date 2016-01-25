class Admin::CommunityPeopleController < ApplicationController

  before_filter :ensure_is_admin
  before_filter :fetch_person

  def edit
    @custom_field_questions = CustomField.for_roles(@person.roles)
  end

  def update
    if params[:custom_fields]
      @person.custom_field_values = FieldValueCreator.call(params[:custom_fields])
    end

    if @person.update_attributes(params[:person])
      Delayed::Job.enqueue(MixpanelIdentifierJob.new(@person.id, @current_community.id))
      flash[:notice] = t("layouts.notifications.person_updated_successfully")
    else
      flash[:error] = t("layouts.notifications.#{@person.errors.first}")
    end

    redirect_to :back
  end

  # Edit the role
  def roles
    @roles = @current_community.roles
  end

  private

  def fetch_person
    @person = Person.find(params[:id])
  end

end
