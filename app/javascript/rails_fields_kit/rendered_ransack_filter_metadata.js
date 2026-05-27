const TABLE_ADAPTER_DATASET_KEYS = Object.freeze({
  adapter: "railsFieldsKitTomSelectTableAdapterValue",
  paramName: "railsFieldsKitTomSelectTableAdapterParamNameValue",
  fields: "railsFieldsKitTomSelectTableAdapterFieldsValue"
})

function parseRenderedRansackFields(rawFields) {
  if (!rawFields) return {}

  try {
    const parsed = JSON.parse(rawFields)
    return parsed && typeof parsed === "object" && !Array.isArray(parsed) ? parsed : {}
  } catch {
    return {}
  }
}

export function readRenderedRansackFilterMetadata(element) {
  const dataset = element?.dataset
  if (!dataset) return null

  const adapter = dataset[TABLE_ADAPTER_DATASET_KEYS.adapter]
  if (adapter !== "ransack") return null

  return {
    adapter,
    paramName: dataset[TABLE_ADAPTER_DATASET_KEYS.paramName] || null,
    fields: parseRenderedRansackFields(dataset[TABLE_ADAPTER_DATASET_KEYS.fields])
  }
}
