import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["items", "quantity", "unitPrice", "totalPrice", "grandTotal"]

  connect() {
    this.calculateAllTotals()
  }

  calculateAllTotals() {
    let grandTotal = 0
    this.itemTargets.forEach(item => {
      const quantity = parseFloat(item.querySelector('[name*="[quantity]"]').value) || 0
      const unitPrice = parseFloat(item.querySelector('[name*="[unit_price]"]').value) || 0
      const total = quantity * unitPrice
      item.querySelector('[name*="[total_price]"]').value = total.toFixed(2)
      grandTotal += total
    })
    
    if (this.hasGrandTotalTarget) {
      this.grandTotalTarget.value = grandTotal.toFixed(2)
    }
  }

  // Called when a new nested field is added by Cocoon
  itemAdded(event) {
    this.calculateAllTotals()
  }

  // Called when a nested field is removed
  itemRemoved(event) {
    this.calculateAllTotals()
  }

  // Called when quantity or unit price changes
  recalculate(event) {
    this.calculateAllTotals()
  }
} 