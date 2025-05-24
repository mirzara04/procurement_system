module VendorsHelper
  def vendor_status_color(status)
    case status
    when 'active'
      'success'
    when 'inactive'
      'secondary'
    when 'blacklisted'
      'danger'
    when 'pending_approval'
      'warning'
    else
      'secondary'
    end
  end

  def render_star_rating(rating)
    full_stars = rating.to_i
    half_star = (rating - full_stars) >= 0.5
    empty_stars = 5 - full_stars - (half_star ? 1 : 0)

    stars = ""
    full_stars.times { stars += '<i class="bi bi-star-fill star-rating"></i>' }
    stars += '<i class="bi bi-star-half star-rating"></i>' if half_star
    empty_stars.times { stars += '<i class="bi bi-star star-empty"></i>' }

    stars.html_safe
  end

  def vendor_performance_badge(rating)
    case rating
    when 4.5..5.0
      content_tag(:span, 'Excellent', class: 'badge bg-success')
    when 3.5...4.5
      content_tag(:span, 'Good', class: 'badge bg-primary')
    when 2.5...3.5
      content_tag(:span, 'Average', class: 'badge bg-warning')
    else
      content_tag(:span, 'Poor', class: 'badge bg-danger')
    end
  end

  def vendor_document_status_color(status)
    case status
    when 'active'
      'success'
    when 'expired'
      'danger'
    when 'pending'
      'warning'
    else
      'secondary'
    end
  end

  def vendor_document_icon(document_type)
    case document_type
    when 'registration'
      'bi-file-earmark-text'
    when 'tax'
      'bi-file-earmark-spreadsheet'
    when 'certification'
      'bi-file-earmark-check'
    when 'contract'
      'bi-file-earmark-pdf'
    when 'insurance'
      'bi-shield-check'
    else
      'bi-file-earmark'
    end
  end

  def vendor_rating_badge(rating)
    return 'N/A' unless rating

    color = case rating.round
            when 5 then 'success'
            when 4 then 'info'
            when 3 then 'warning'
            else 'danger'
            end

    content_tag :span, class: "badge bg-#{color}" do
      "#{rating.round(1)} ★"
    end
  end
end 