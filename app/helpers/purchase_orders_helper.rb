module PurchaseOrdersHelper
  def po_status_color(status)
    case status&.to_sym
    when :draft then 'secondary'
    when :pending_approval then 'warning'
    when :approved then 'success'
    when :in_progress then 'primary'
    when :rejected then 'danger'
    when :cancelled then 'dark'
    when :delivered then 'info'
    else 'secondary'
    end
  end

  def order_status_color(status)
    case status&.to_sym
    when :draft then 'secondary'
    when :pending_approval then 'warning'
    when :approved then 'success'
    when :rejected then 'danger'
    when :cancelled then 'dark'
    when :delivered then 'info'
    else 'secondary'
    end
  end

  def format_status(status)
    return 'Draft' if status.nil?
    status.to_s.humanize
  end

  def po_version_event(version)
    case version.event
    when 'create'
      'Purchase Order Created'
    when 'update'
      changes = version.changeset.keys
      if changes.include?('status')
        "Status Changed to #{format_status(version.changeset['status'].last)}"
      else
        "Purchase Order Updated"
      end
    else
      version.event.humanize
    end
  end

  def po_version_details(version)
    return '' unless version.event == 'update'
    
    changes = []
    version.changeset.each do |attribute, (old_value, new_value)|
      next if ['updated_at', 'created_at'].include?(attribute)
      
      case attribute
      when 'status'
        changes << "Status changed from #{format_status(old_value) || 'none'} to #{format_status(new_value)}"
      when 'total_amount'
        changes << "Total amount changed from #{number_to_currency(old_value)} to #{number_to_currency(new_value)}"
      when 'expected_delivery_date'
        old_date = old_value&.to_date&.strftime("%b %d, %Y")
        new_date = new_value.to_date.strftime("%b %d, %Y")
        changes << "Expected delivery date changed from #{old_date || 'none'} to #{new_date}"
      else
        changes << "#{attribute.humanize} was updated"
      end
    end
    
    changes.join(', ')
  end
end 