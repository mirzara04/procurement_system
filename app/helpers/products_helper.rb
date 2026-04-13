module ProductsHelper
  def product_status_color(status)
  case status&.to_sym
  when :active
    'success'
  when :discontinued
    'secondary'
  else
    'default'
  end
end
end 