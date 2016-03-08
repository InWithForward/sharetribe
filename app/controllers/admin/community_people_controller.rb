class Admin::CommunityPeopleController < ApplicationController

  before_filter :ensure_is_admin
  before_filter :fetch_person

  def edit
    @custom_field_questions = CustomField.for_roles(@person.roles)
  end

  def update
    if params[:custom_fields]
      FieldValueCreator.call(params[:custom_fields], @person)
    end

    if @person.update_attributes(params[:person])
      Delayed::Job.enqueue(MixpanelIdentifierJob.new(@person.id, request.remote_ip))
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
