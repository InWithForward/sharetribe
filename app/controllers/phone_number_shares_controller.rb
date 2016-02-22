class PhoneNumberSharesController < ApplicationController

  before_filter do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_this_page")
  end

  PhoneNumberShare = FormUtils.define_form("PhoneNumberShare",
    :phone_number,
  ).with_validations {
    validates_presence_of :phone_number
  }

  def new
    return send_and_redirect if @current_user && @current_user.phone_number.present?

    render :new, locals: { phone_number_share_form: PhoneNumberShare.new }
  end

  def create
    form = PhoneNumberShare.new(params[:phone_number_share])

    if form.valid?
      @current_user.phone_number = form.phone_number
      @current_user.save

      return send_and_redirect
    else
      flash[:error] = form.errors.full_messages.join(", ")
      return redirect_to :back
    end
  end

  private

  def send_and_redirect
    Delayed::Job.enqueue(
      SharePhoneNumberJob.new(@current_user.id, recipient.id, @current_community.id)
    )
    redirect_to root_path
  end

  def recipient
    @recipient ||= Person.find(params[:person_id])
  end

end
