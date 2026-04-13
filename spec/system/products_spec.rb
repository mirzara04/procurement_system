require 'rails_helper'

RSpec.describe "Products", type: :system do
  let(:admin) { create(:user, :admin) }
  let(:procurement_officer) { create(:user, :procurement_officer) }
  let(:regular_user) { create(:user) }
  let(:vendor) { create(:vendor, :active) }

  before do
    driven_by(:rack_test)
  end

  describe 'index page' do
    let!(:active_product) { create(:product, :active, vendor: vendor) }
    let!(:discontinued_product) { create(:product, :discontinued) }
    let!(:low_stock_product) { create(:product, :low_stock) }

    context 'as admin' do
      before { sign_in admin }

      it 'displays all products' do
        visit products_path
        
        expect(page).to have_content(active_product.name)
        expect(page).to have_content(discontinued_product.name)
        expect(page).to have_content(low_stock_product.name)
        expect(page).to have_link('New Product')
      end

      it 'allows filtering products' do
        visit products_path
        
        fill_in 'Name/SKU Contains', with: active_product.sku
        click_button 'Search'
        
        expect(page).to have_content(active_product.name)
        expect(page).not_to have_content(discontinued_product.name)
      end
    end

    context 'as procurement officer' do
      before { sign_in procurement_officer }

      it 'hides discontinued products' do
        visit products_path
        
        expect(page).to have_content(active_product.name)
        expect(page).not_to have_content(discontinued_product.name)
      end
    end
  end

  describe 'show page' do
    let(:product) { create(:product, :active, vendor: vendor) }
    
    before { sign_in admin }

    it 'displays product details' do
      visit product_path(product)
      
      expect(page).to have_content(product.name)
      expect(page).to have_content(product.sku)
      expect(page).to have_content(product.vendor.name)
      expect(page).to have_link('Edit')
    end
  end

  describe 'create product' do
    before { sign_in admin }

    it 'creates a new product' do
      visit new_product_path
      
      fill_in 'Name', with: 'Test Product'
      fill_in 'SKU', with: 'TEST-001'
      select 'Active', from: 'Status'
      select 'Electronics', from: 'Category'
      fill_in 'Unit price', with: '99.99'
      fill_in 'Current stock', with: '50'
      
      expect {
        click_button 'Create Product'
      }.to change(Product, :count).by(1)

      expect(page).to have_content('Test Product')
      expect(page).to have_content('TEST-001')
    end
  end

  describe 'edit product' do
    let(:product) { create(:product, :active) }
    
    before { sign_in admin }

    it 'updates product details' do
      visit edit_product_path(product)
      
      fill_in 'Name', with: 'Updated Product'
      click_button 'Update Product'
      
      expect(page).to have_content('Updated Product')
    end
  end

  describe 'low stock page' do
    let!(:low_stock_product) { create(:product, :low_stock) }
    let!(:normal_stock_product) { create(:product, :active) }
    
    before { sign_in procurement_officer }

    it 'shows only low stock products' do
      visit low_stock_products_path
      
      expect(page).to have_content(low_stock_product.name)
      expect(page).not_to have_content(normal_stock_product.name)
    end
  end

  describe 'discontinued page' do
    let!(:discontinued_product) { create(:product, :discontinued) }
    let!(:active_product) { create(:product, :active) }
    
    before { sign_in admin }

    it 'shows only discontinued products' do
      visit discontinued_products_path
      
      expect(page).to have_content(discontinued_product.name)
      expect(page).not_to have_content(active_product.name)
    end
  end
end 