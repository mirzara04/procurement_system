module VendorsHelper
  # Status colors with more robust nil handling
  def vendor_status_color(status)
    status = normalize_status(status)
    case status.downcase
    when 'active'          then 'success'
    when 'inactive'        then 'secondary'
    when 'blacklisted'     then 'danger'
    when 'pending_approval'then 'warning'
    else 'primary'
    end
  end

  # Status formatting with better i18n support
  def format_vendor_status(status)
    status = normalize_status(status)
    I18n.t("vendor.statuses.#{status.downcase}", default: status.humanize.titleize)
  rescue
    'Unknown Status'
  end

  # Star rating with more precise decimal handling
  def render_star_rating(rating)
    rating = rating.to_f
    full_stars = rating.floor
    half_star = (rating - full_stars) >= 0.5 ? 1 : 0
    empty_stars = 5 - full_stars - half_star

    safe_join([
      ('<i class="bi bi-star-fill star-rating"></i>' * full_stars).html_safe,
      ('<i class="bi bi-star-half star-rating"></i>' * half_star).html_safe,
      ('<i class="bi bi-star star-empty"></i>' * empty_stars).html_safe
    ])
  end

  # Performance badge with range boundary fixes
  def vendor_performance_badge(rating)
    rating = rating.to_f
    text, klass = case rating
                  when 4.5..5.0   then ['Excellent', 'success']
                  when 3.5...4.5  then ['Good', 'primary']
                  when 2.5...3.5  then ['Average', 'warning']
                  else                 ['Poor', 'danger']
                  end
    content_tag(:span, text, class: "badge bg-#{klass}")
  end

  # Document status with better defaults
  def vendor_document_status_color(status)
    status = status.presence || 'unknown'
    case status.downcase
    when 'active'  then 'success'
    when 'expired' then 'danger'
    when 'pending' then 'warning'
    else 'secondary'
    end
  end

  # Document icons with more options
  def vendor_document_icon(document_type)
    case document_type.to_s.downcase
    when 'registration'  then 'bi-file-earmark-text'
    when 'tax'          then 'bi-file-earmark-spreadsheet'
    when 'certification'then 'bi-file-earmark-check'
    when 'contract'     then 'bi-file-earmark-pdf'
    when 'insurance'    then 'bi-shield-check'
    when 'license'      then 'bi-file-earmark-lock'
    when 'financial'    then 'bi-file-earmark-bar-graph'
    else 'bi-file-earmark'
    end
  end

  private

  # Normalize status values
  def normalize_status(status)
    status = status.presence || 'active'
    status.to_s.downcase
  end
end