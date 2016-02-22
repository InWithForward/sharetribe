module ListingCSV

  module_function

  def header
    [
      "ID",
      I18n.t("admin.communities.listings.title"),
      I18n.t("admin.communities.listings.whats_missing"),
      I18n.t("admin.communities.listings.author"),
      I18n.t("admin.communities.listings.invisible"),
      I18n.t("admin.communities.listings.open")
    ]
  end

  def row(listing)
    [
      listing.id,
      listing.title,
      listing.missing_prerequisites.map { |option| option.title(I18n.locale) }.join(", "),
      listing.author.full_name,
      listing.invisible,
      listing.open
    ]
  end
end
