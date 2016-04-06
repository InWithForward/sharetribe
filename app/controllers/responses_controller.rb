class ResponsesController < ActionController::Base

  def create
    Delayed::Job.enqueue(
      MessageFromResponseJob.new(params)
    )

    render status: 200, nothing: true
  end
end
