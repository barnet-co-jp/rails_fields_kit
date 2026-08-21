import BaseTomSelectController from "./tom_select_controller_base.js"

export default class extends BaseTomSelectController {
  static values = {
    ...BaseTomSelectController.values,
    addPrecedence: Boolean,
    createOnBlur: Boolean,
    clearAfterSelect: Boolean
  }

  options() {
    const options = super.options()

    if (this.hasAddPrecedenceValue) options.addPrecedence = this.addPrecedenceValue
    if (this.hasCreateOnBlurValue) options.createOnBlur = this.createOnBlurValue
    if (this.hasClearAfterSelectValue) options.clearAfterSelect = this.clearAfterSelectValue

    return options
  }
}
