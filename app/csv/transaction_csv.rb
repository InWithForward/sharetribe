module TransactionCSV
  extend TransactionHelper

  module_function

  def header
    [
      "ID",
      I18n.t("admin.communities.transactions.csv_headers.listing"),
      I18n.t("admin.communities.transactions.csv_headers.status"),
      I18n.t("admin.communities.transactions.csv_headers.started"),
      I18n.t("admin.communities.transactions.csv_headers.last_activity"),
      I18n.t("admin.communities.transactions.csv_headers.initiated_by"),
      I18n.t("admin.communities.transactions.csv_headers.other_party"),
      I18n.t("admin.communities.transactions.csv_headers.booking_at")
    ]
  end

  def row(transaction, args = {})
    [
      transaction[:id],
      transaction[:listing][:title],
      I18n.t("admin.communities.transactions.status.#{transaction[:status]}"),
      I18n.l(transaction[:created_at], format: :short_date),
      last_activity_at(transaction),
      transaction[:starter][:display_name],
      transaction[:author][:display_name],
      Maybe(transaction[:booking]).map { |b| I18n.l(b.start_at) }.or_else(nil)
    ]
  end
end
