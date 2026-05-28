const ERROR_SURFACE_DATASET_KEY = "railsFieldsKitTomSelectErrorSurfaceIdValue"

export function readRenderedErrorSurface(element) {
  const dataset = element?.dataset
  const errorSurfaceId = dataset?.[ERROR_SURFACE_DATASET_KEY]
  if (!errorSurfaceId) return null

  const ownerDocument = element.ownerDocument
  if (!ownerDocument || typeof ownerDocument.getElementById !== "function") return null

  return ownerDocument.getElementById(errorSurfaceId)
}
