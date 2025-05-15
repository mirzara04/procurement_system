module PurchaseOrdersHelper
  def po_status_color(status)
    case status
    when 'draft'
      'secondary'
    when 'pending_approval'
      'warning'
    when 'approved'
      'info'
    when 'in_progress'
      'primary'
    when 'delivered'
      'success'
    when 'cancelled'
      'danger'
    else
      'secondary'
    end
  end

  def po_version_event(version)
    case version.event
    when 'create'
      'Purchase Order Created'
    when 'update'
      changes = version.changeset.keys
      if changes.include?('status')
        "Status Changed to #{version.changeset['status'].last.titleize}"
      else
        "Purchase Order Updated"
      end
    else
      version.event.titleize
    end
  end

  def po_version_details(version)
    return '' unless version.event == 'update'
    
    changes = []
    version.changeset.each do |attribute, (old_value, new_value)|
      next if ['updated_at', 'created_at'].include?(attribute)
      
      case attribute
      when 'status'
        changes << "Status changed from #{old_value&.titleize || 'none'} to #{new_value.titleize}"
      when 'total_amount'
        changes << "Total amount changed from #{number_to_currency(old_value)} to #{number_to_currency(new_value)}"
      when 'expected_delivery_date'
        old_date = old_value&.to_date&.strftime("%b %d, %Y")
        new_date = new_value.to_date.strftime("%b %d, %Y")
        changes << "Expected delivery date changed from #{old_date || 'none'} to #{new_date}"
      else
        changes << "#{attribute.titleize} was updated"
      end
    end
    
    changes.join(', ')
  end
end 