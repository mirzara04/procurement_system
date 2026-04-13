require 'rails_helper'

RSpec.describe Product, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

def product_status_color(status)
  case status&.to_sym
  when :active
    'success'
  when :discontinued
    'secondary'
  else
    'default' # or any fallback class you want
  end
end
