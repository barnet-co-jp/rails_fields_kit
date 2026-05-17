# Rails Fields Kit Public API

This document summarizes the public API intended to be stable for the 0.1.x series.

## Ruby entrypoint

```ruby
require "rails_fields_kit"
```

## Configuration

```ruby
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
end
```

Public configuration methods:

- `RailsFieldsKit.configuration`
- `RailsFieldsKit.configure`
- `RailsFieldsKit.reset_configuration!`

Configuration attributes are documented in [`configuration.md`](configuration.md).

## FormBuilder helpers

Tom Select-backed helpers:

- `rfk_select`
- `rfk_combobox`
- `rfk_autocomplete`
- `rfk_tags`
- `rfk_multi_select`
- `rfk_grouped_select`
- `rfk_enum_select`

Native input helpers:

- `rfk_text_field`
- `rfk_text_area`
- `rfk_number_field`
- `rfk_money_field`
- `rfk_percent_field`
- `rfk_email_field`
- `rfk_url_field`
- `rfk_phone_field`
- `rfk_search_field`

See [`field_helpers.md`](field_helpers.md) for details.

## Controller helpers

Include `RailsFieldsKit::Searchable` in controllers that serve remote option JSON.

Public class methods:

- `rfk_search_with`
- `rfk_find_with`
- `rfk_create_with`

See [`controller_helpers.md`](controller_helpers.md) for details.

## JavaScript exports

The package exposes the Tom Select Stimulus controller from the JavaScript entrypoint:

```js
import { TomSelectController } from "rails_fields_kit"
```

Direct import is also supported:

```js
import TomSelectController from "rails_fields_kit/tom_select_controller"
```

## Stimulus events

Events dispatched by the Tom Select controller are part of the public integration surface.

See [`events.md`](events.md).

## Internal implementation details

These are not intended as stable public APIs:

- private FormBuilder helper methods prefixed with `rfk_` but defined under `private`
- internal normalization methods in `RailsFieldsKit::Searchable`
- exact HTML structure of rich option rendering beyond documented classes/data and event payloads
- generated documentation wording

## Compatibility policy

For the 0.1.x series, small API adjustments may still happen, but documented public APIs should not be removed without a changelog entry.
