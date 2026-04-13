module ReportsHelper
  def vendor_status_color(status)
    case status&.to_sym
    when :active
      'success'
    when :inactive
      'secondary'
    when :blacklisted
      'danger'
    when :pending_approval
      'warning'
    else
      'primary'
    end
  end

  def product_status_color(status)
    case status&.to_sym
    when :active
      'success'
    when :discontinued
      'danger'
    when :out_of_stock
      'warning'
    else
      'primary'
    end
  end

  def render_star_rating(rating)
    return 'No ratings' if rating.nil?
    
    full_stars = rating.floor
    half_star = (rating - full_stars) >= 0.5
    empty_stars = 5 - full_stars - (half_star ? 1 : 0)
    
    html = ''
    full_stars.times { html += '<i class="bi bi-star-fill text-warning"></i>' }
    html += '<i class="bi bi-star-half text-warning"></i>' if half_star
    empty_stars.times { html += '<i class="bi bi-star text-warning"></i>' }
    
    html.html_safe
  end
end 