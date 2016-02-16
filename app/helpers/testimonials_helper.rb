module TestimonialsHelper

  def received_testimonials_for_person(person, current_user, current_community)
    scope = @person.received_testimonials

    # Show all testimonials if Admin
    if Maybe(current_user).has_admin_rights_in?(current_community).or_else { false }
      scope
    else # Scope testimonials if non Admin
      scope.where(state: 'accepted') 
    end
  end

end
