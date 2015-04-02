class Admin::CommunityPeopleController < ApplicationController

  before_filter :ensure_is_admin
  before_filter :fetch_person

  def update
    if @person.update_attributes(params[:person])
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
