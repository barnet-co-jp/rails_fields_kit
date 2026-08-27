import BaseTomSelectController from "./tom_select_controller_base.js"

export default class extends BaseTomSelectController {
  static values = {
    ...BaseTomSelectController.values,
    addPrecedence: Boolean,
    createOnBlur: Boolean,
    clearAfterSelect: Boolean
  }

  connect() {
    super.connect()
    this.bindEditableFreeTextLookupFocus()
  }

  options() {
    const options = super.options()

    if (this.hasAddPrecedenceValue) options.addPrecedence = this.addPrecedenceValue
    if (this.hasCreateOnBlurValue) options.createOnBlur = this.createOnBlurValue
    if (this.hasClearAfterSelectValue) options.clearAfterSelect = this.clearAfterSelectValue

    return options
  }

  dispatch(eventName, options = {}) {
    if (this.restoringFreeTextLookup && ["change", "item-remove", "clear"].includes(eventName)) return

    return super.dispatch(eventName, options)
  }

  bindEditableFreeTextLookupFocus() {
    if (!this.editableFreeTextLookup() || !this.tomSelect) return

    this.tomSelect.on("focus", () => this.restoreFreeTextLookupForEditing())
  }

  editableFreeTextLookup() {
    return this.kindValue === "lookup" && this.freeTextValue && this.createOnBlurValue
  }

  restoreFreeTextLookupForEditing() {
    if (!this.editableFreeTextLookup() || !this.tomSelect) return

    const values = this.selectedValues().filter((value) => this.hasPresentValue(value))
    if (values.length !== 1) return

    const value = values[0]
    const key = String(value)
    const userOptions = this.tomSelect.userOptions || {}
    if (!Object.prototype.hasOwnProperty.call(userOptions, key)) return

    const option = this.optionForValue(value)
    const text = option ? this.optionLabel(option) : this.displayValue(value)
    if (!this.hasPresentValue(text)) return

    this.restoringFreeTextLookup = true
    try {
      this.tomSelect.removeItem(value, true)
    } finally {
      this.restoringFreeTextLookup = false
    }

    const textField = this.lookupTextField()
    if (textField) textField.value = text

    const idField = this.lookupIdField()
    if (idField) idField.value = ""

    this.tomSelect.setTextboxValue(text)

    if (this.hasUrlValue && text.length >= this.minLengthValue && typeof this.tomSelect.load === "function") {
      this.tomSelect.load(text)
    }
  }
}
