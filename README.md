# Rails Fields Kit

Rails Fields Kit is a Rails form helper kit for fields that are still awkward with native HTML inputs alone: searchable selects, editable comboboxes, tag inputs, autocomplete, and create-on-the-fly fields.

The first focus is a Tom Select powered editable combobox for Rails forms.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "rails_fields_kit"
```

Then install:

```bash
bundle install
```

Rails Fields Kit expects your JavaScript application to provide `@hotwired/stimulus` and `tom-select`.

## Usage

### Editable combobox

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_combobox :customer_id,
    url: customers_path(format: :json),
    create_url: customers_path,
    value_field: "id",
    label_field: "name",
    search_field: "name,email",
    query_param: "q",
    create_param: "name",
    min_length: 2,
    placeholder: "Search or create a customer" %>
<% end %>
```

The search endpoint can return an array:

```json
[
  { "id": 1, "name": "Example Customer" }
]
```

or a wrapped result:

```json
{ "options": [{ "id": 1, "name": "Example Customer" }] }
```

The create endpoint should return the created option object:

```json
{ "id": 2, "name": "New Customer" }
```

### Normal select wrapper

```erb
<%= f.rfk_select :status, collection: Order.statuses.keys %>
```

### Tag-style multi select

```erb
<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  create: true %>
```

### Autocomplete text field

```erb
<%= f.rfk_autocomplete :keyword,
  url: suggestions_path(format: :json),
  free_text: true %>
```

## Configuration

```ruby
# config/initializers/rails_fields_kit.rb
RailsFieldsKit.configure do |config|
  config.default_query_param = "q"
  config.default_create_param = "text"
  config.default_value_field = "value"
  config.default_label_field = "text"
  config.default_search_field = "text"
  config.default_min_length = 0
end
```

## Design principles

Rails Fields Kit does not try to replace native HTML inputs when browsers already provide a good default, such as date, time, color, email, URL, or number inputs.

Instead, it focuses on the gaps that remain common in Rails business applications:

- searchable selects
- editable comboboxes
- autocomplete text fields
- tag inputs
- remote option loading
- create-on-the-fly records
- Active Model friendly naming, values, errors, and redisplay

Select-like fields are powered by Tom Select. When Tom Select already supports the behavior directly, Rails Fields Kit acts as a thin Rails wrapper. When Rails integration is the hard part, such as initial value preload or create-on-the-fly records, Rails Fields Kit provides a higher-level field helper.

## Development

```bash
git pull
bundle install
bundle exec rspec
```

CI is intentionally not required during early implementation.
