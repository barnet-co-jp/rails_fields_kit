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

export interface TomSelectRequestParamsContract {
  queryParams: Record<string, unknown>
  selectedQueryParams: Record<string, unknown>
  createParams: Record<string, unknown>
}

export interface SelectedPreloadConfig {
  selectedUrl: string
  selectedParam: string
  selectedMultipleParam: string
  selectedQueryParams: Record<string, unknown>
}

export interface NativeFieldAccessibilityContract {
  describedByIds: string[]
  describedByElements: Element[]
  labelElement: HTMLLabelElement | null
  hintElement: Element | null
  errorElement: Element | null
  wrapperElement: Element | null
  required: boolean
  disabled: boolean
  readonly: boolean
}

export function tomSelectTextOverrideContract(element: Element | null | undefined): TomSelectTextOverrideContract | null
export function tomSelectPluginContract(element: Element | null | undefined): TomSelectPluginContract | null
export function tomSelectRequestParamsContract(element: Element | null | undefined): TomSelectRequestParamsContract | null
export function readRenderedSelectedPreloadConfig(element: Element | null | undefined): SelectedPreloadConfig | null
export function nativeFieldAccessibilityContract(element: Element | null | undefined): NativeFieldAccessibilityContract | null

export { TomSelectController }
export default TomSelectController
