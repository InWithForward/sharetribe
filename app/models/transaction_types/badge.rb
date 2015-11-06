
class Badge < TransactionType

  DEFAULTS = {}

  def direction
    "badge"
  end

  def is_offer?
    false
  end

  def is_request?
    false
  end

  def is_inquiry?
    false
  end

  def is_badge?
    true
  end
end
