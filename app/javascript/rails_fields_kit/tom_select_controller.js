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

    if (eventName === "item-add") {
      this.normalizeAcceptedLookupItem(options.detail && options.detail.value)
    }

    return super.dispatch(eventName, options)
  }

  loadSelectedOptions() {
    this.hydrateLookupInitialOption()
    return super.loadSelectedOptions()
  }

  selectedValuesNeedingOptions() {
    return this.selectedValues().filter((value) => {
      if (!this.hasPresentValue(value)) return false

      return !this.optionForValue(value) || this.selectedOptionNeedsHydration(value)
    })
  }

  selectedOptionNeedsHydration(value) {
    const option = this.optionForValue(value)
    if (this.pendingSelectedLabelOption(option)) return true
    if (this.kindValue !== "lookup") return false

    const idField = this.lookupIdField()
    const textField = this.lookupTextField()
    return Boolean(
      idField &&
        this.hasPresentValue(idField.value) &&
        String(idField.value) === String(value) &&
        (!textField || !this.hasPresentValue(textField.value))
    )
  }

  pendingSelectedLabelOption(option) {
    if (!option) return false
    if (option.rfkSelectedLabelPending === true || option.rfkSelectedLabelPending === "true") return true

    const element = option.$option
    if (!element) return false
    if (element.dataset && element.dataset.rfkSelectedLabelPending === "true") return true

    return typeof element.getAttribute === "function" && element.getAttribute("data-rfk-selected-label-pending") === "true"
  }

  applySelectedOptions(json, requestedValues = []) {
    const options = this.normalizeSelectedOptions(json).filter((option) => this.optionHasValue(option))
    const valueField = this.optionValueField()

    options.forEach((option) => {
      const value = option[valueField]
      const existing = this.optionForValue(value)
      this.clearPendingSelectedLabelMarker(existing)

      if (existing && typeof this.tomSelect.updateOption === "function") {
        this.tomSelect.updateOption(value, { ...existing, ...option })
      } else if (existing) {
        Object.assign(existing, option)
      } else {
        this.tomSelect.addOption(option)
      }

      this.tomSelect.addItem(value, true)
    })

    if (this.kindValue === "lookup" && options.length > 0) {
      const selectedValue = this.selectedValues().find((value) => this.hasPresentValue(value))
      if (this.hasPresentValue(selectedValue)) this.syncLookupSelection(selectedValue)
    }

    this.tomSelect.refreshOptions(false)
    this.clearErrorSurface()
    this.dispatch("selected-load", { detail: { options, values: requestedValues } })
  }

  clearPendingSelectedLabelMarker(option) {
    if (!option) return

    delete option.rfkSelectedLabelPending
    const element = option.$option
    if (!element) return

    if (element.dataset) delete element.dataset.rfkSelectedLabelPending
    if (typeof element.removeAttribute === "function") element.removeAttribute("data-rfk-selected-label-pending")
  }

  hydrateLookupInitialOption() {
    if (this.kindValue !== "lookup" || !this.tomSelect) return

    const idField = this.lookupIdField()
    const textField = this.lookupTextField()
    const value = idField && idField.value
    const text = textField && textField.value
    if (!this.hasPresentValue(value) || !this.hasPresentValue(text)) return

    const valueField = this.optionValueField()
    const option = {
      [valueField]: value,
      [this.labelFieldValue || "text"]: text
    }
    if (this.hasDisplayFieldValue) option[this.displayFieldValue] = text

    const existing = this.optionForValue(value)
    if (existing && typeof this.tomSelect.updateOption === "function") {
      this.tomSelect.updateOption(value, { ...existing, ...option })
    } else if (existing) {
      Object.assign(existing, option)
    } else {
      this.tomSelect.addOption(option)
    }

    this.tomSelect.addItem(value, true)
  }

  normalizeAcceptedLookupItem(value) {
    if (this.kindValue !== "lookup" || !this.tomSelect) return
    if (!this.optionForValue(value)) return

    this.syncLookupSelection(value)

    if (typeof this.tomSelect.setTextboxValue === "function") {
      this.tomSelect.setTextboxValue("")
    }
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
