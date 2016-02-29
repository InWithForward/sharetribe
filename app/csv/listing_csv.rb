module ListingCSV

  module_function

  def header
    [
      "ID",
      I18n.t("admin.communities.listings.title"),
      I18n.t("admin.communities.listings.author"),
      I18n.t("admin.communities.listings.invisible"),
      I18n.t("admin.communities.listings.open"),
      PrerequisiteService.options.map { |option| option.title(I18n.locale) }
    ].flatten
  end

  def row(listing)
    [
      listing.id,
      listing.title,
      listing.author.full_name,
      listing.invisible,
      listing.open,
      PrerequisiteService.options_status_array(listing)
    ].flatten
  end
end
