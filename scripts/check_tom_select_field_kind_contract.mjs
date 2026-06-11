import assert from "node:assert/strict"
import { tomSelectFieldKindContract } from "../app/javascript/rails_fields_kit/index.js"

class FakeElement {
  constructor(attributes = {}) {
    this.attributes = attributes
  }

  getAttribute(name) {
    return Object.hasOwn(this.attributes, name) ? this.attributes[name] : null
  }

  hasAttribute(name) {
    return Object.hasOwn(this.attributes, name)
  }
}

assert.deepEqual(
  tomSelectFieldKindContract(new FakeElement({
    "data-controller": "other rails-fields-kit--tom-select",
    "data-rails-fields-kit--tom-select-kind-value": "grouped_select"
  })),
  {
    controller: "rails-fields-kit--tom-select",
    kind: "grouped_select"
  },
  "field kind contract reader should expose the rendered helper kind for Rails Fields Kit Tom Select fields"
)

assert.equal(
  tomSelectFieldKindContract(new FakeElement({
    "data-controller": "rails-fields-kit--tom-select"
  })),
  null,
  "field kind contract reader should return null when the rendered kind value is absent"
)

assert.equal(
  tomSelectFieldKindContract(new FakeElement({
    "data-controller": "other",
    "data-rails-fields-kit--tom-select-kind-value": "select"
  })),
  null,
  "field kind contract reader should ignore non-Rails Fields Kit Tom Select elements"
)

assert.equal(
  tomSelectFieldKindContract(null),
  null,
  "field kind contract reader should ignore missing elements"
)

console.log("rails_fields_kit Tom Select field kind contract smoke passed")
