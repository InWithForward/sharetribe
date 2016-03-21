class ErrorsController < ActionController::Base

  layout 'blank_layout'
  before_filter :current_community
  before_filter :set_locale

  def server_error
    render "status_500", status: 500, locals: { status: 500, title: title(500) }
  end

  def not_found
    render "status_404", status: 404, locals: { status: 404, title: title(404) }
  end

  def gone
    render "status_410", status: 410, locals: { status: 410, title: title(410) }
  end

  def community_not_found
    render status: 404, locals: { status: 404, title: "Marketplace not found", host: request.host }
  end

  private

  def current_community
    @current_community ||= ApplicationController.default_community_fetch_strategy(request.host)
  end

  def title(status)
    community_name = Maybe(@current_community).map { |c|
      c.name(community_locale)
    }.or_else(nil)

    [community_name, t("error_pages.error_#{status}_title")].compact.join(' - ')
  end

  def community_locale
    Maybe(@current_community).default_locale.or_else(nil)
  end

  def set_locale
    I18n.locale = community_locale || "en"
  end

  def exception
    env["action_dispatch.exception"]
  end
end
