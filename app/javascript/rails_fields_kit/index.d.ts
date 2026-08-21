import TomSelectController from "./tom_select_controller.js"

export interface TomSelectTextOverrideContract {
  noResultsText: string | null
  loadingText: string | null
  createText: string | null
}

export interface TomSelectPluginContract {
  plugins: string[]
  hasClearButton: boolean
  hasRemoveButton: boolean
}

export interface TomSelectSelectionContract {
  values: unknown[]
}

export interface TomSelectRequestContract {
  controller: string
  hasRemoteSearch: boolean
  hasSelectedPreload: boolean
  hasCreateEndpoint: boolean
  url: string | null
  selectedUrl: string | null
  createUrl: string | null
  queryParam: string
  queryParams: Record<string, unknown>
  selectedParam: string
  selectedMultipleParam: string
  createParam: string
  createParams: Record<string, unknown>
  minLength: number
  errorSurfaceId: string | null
}

export interface TomSelectFieldKindContract {
  controller: string
  kind: string
}

export interface TomSelectInteractionConfig {
  maxOptions: number | null
  maxItems: number | null
  loadThrottle: number | null
  delimiter: string | null
  dropdownParent: string | null
  preload: boolean | null
  openOnFocus: boolean | null
  closeAfterSelect: boolean | null
  hideSelected: boolean | null
  persist: boolean
}

export interface SelectedPreloadConfig {
  selectedUrl: string
  selectedParam: string
  selectedMultipleParam: string
  selectedQueryParams: Record<string, unknown>
}

export interface OptionPayloadMapping {
  valueField: string
  labelField: string
  searchFields: string[]
  optionDescriptionField: string | null
  optionBadgeField: string | null
}

export interface TableFilterMetadata {
  adapter: string
  paramName: string | null
  fields: Record<string, unknown>
}

export interface NativeFieldAccessibilityContract {
  describedByIds: string[]
  describedByElements: Element[]
  labelElement: HTMLLabelElement | null
  hintElement: Element | null
  errorElement: Element | null
  prefixElement: Element | null
  suffixElement: Element | null
  wrapperElement: Element | null
}

export interface NativeFieldConstraintContract {
  maxLength: string | null
  minLength: string | null
  pattern: string | null
  autocomplete: string | null
  inputMode: string | null
}

export function tomSelectTextOverrideContract(element: Element | null | undefined): TomSelectTextOverrideContract | null
export function tomSelectPluginContract(element: Element | null | undefined): TomSelectPluginContract | null
export function tomSelectSelectionContract(element: Element | null | undefined): TomSelectSelectionContract | null
export function tomSelectRequestContract(element: Element | null | undefined): TomSelectRequestContract | null
export function tomSelectFieldKindContract(element: Element | null | undefined): TomSelectFieldKindContract | null
export function readRenderedTomSelectInteractionConfig(element: Element | null | undefined): TomSelectInteractionConfig | null
export function readRenderedErrorSurface(element: Element | null | undefined): Element | null
export function readRenderedSelectedPreloadConfig(element: Element | null | undefined): SelectedPreloadConfig | null
export function readRenderedOptionPayloadMapping(element: Element | null | undefined): OptionPayloadMapping | null
export function readRenderedTableFilterMetadata(element: Element | null | undefined): TableFilterMetadata | null
export function nativeFieldAccessibilityContract(element: Element | null | undefined): NativeFieldAccessibilityContract | null
export function nativeFieldConstraintContract(element: Element | null | undefined): NativeFieldConstraintContract | null

export { TomSelectController }
export default TomSelectController
