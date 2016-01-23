class Admin::CommunityPeopleController < ApplicationController

  before_filter :ensure_is_admin
  before_filter :fetch_person

  def edit
    @custom_field_questions = @current_community.person_custom_fields
  end

  def update
    @person.custom_field_values = FieldValueCreator.call(params[:custom_fields])

    if @person.update_attributes(params[:person])
      Delayed::Job.enqueue(MixpanelIdentifierJob.new(@person.id, @current_community.id))
      flash[:notice] = t("layouts.notifications.person_updated_successfully")
    else
      flash[:error] = t("layouts.notifications.#{@person.errors.first}")
    end

    redirect_to :back
  end

  private

  def fetch_person
    @person = Person.find(params[:id])
  end

end
