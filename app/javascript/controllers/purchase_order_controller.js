import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["itemTotal", "grandTotal"]

  connect() {
    this.updateGrandTotal()
  }

  updateItemTotal(event) {
    const row = event.target.closest('.item-row')
    const quantity = parseFloat(row.querySelector('.quantity-field').value) || 0
    const price = parseFloat(row.querySelector('.price-field').value) || 0
    const total = (quantity * price).toFixed(2)
    
    row.querySelector('[data-purchase-order-target="itemTotal"]').textContent = 
      new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(total)

    this.updateGrandTotal()
  }

  updateGrandTotal() {
    let grandTotal = 0
    this.itemTotalTargets.forEach(element => {
      const amount = parseFloat(element.textContent.replace(/[^0-9.-]+/g, "")) || 0
      grandTotal += amount
    })

    if (this.hasGrandTotalTarget) {
      this.grandTotalTarget.textContent = new Intl.NumberFormat('en-US', {
        style: 'currency',
        currency: 'USD'
      }).format(grandTotal)
    }
  }
} 