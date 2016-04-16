module MembershipCSV

  module_function

  def header
    [
      I18n.t("admin.communities.manage_members.name"),
      I18n.t("admin.communities.manage_members.email"),
      I18n.t("admin.communities.manage_members.join_date"),
      I18n.t("admin.communities.manage_members.posting_allowed"),
      I18n.t("admin.communities.manage_members.requesting_allowed"),
      I18n.t("admin.communities.manage_members.admin"),
      I18n.t("admin.communities.manage_members.role")
    ].flatten
  end

  def row(membership, args = {})
    community = args[:community]
    member = membership.person

    [
      member.full_name,
      member.confirmed_notification_email_addresses.first,
      I18n.l(membership.created_at, format: :short_date),
      membership.can_post_listings,
      membership.can_request_listings,
      member.is_admin_of?(community),
      member.roles.map(&:name)
    ].flatten
  end
end
