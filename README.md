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

## Usage

```erb
<%= form_with model: @order do |f| %>
  <%= f.rfk_combobox :customer_id,
    url: customers_path(format: :json),
    create_url: customers_path,
    placeholder: "Search or create a customer" %>
<% end %>
```

For a normal Tom Select wrapper:

```erb
<%= f.rfk_select :status, collection: Order.statuses.keys %>
```

For tag-style multi select:

```erb
<%= f.rfk_tags :tag_ids,
  url: tags_path(format: :json),
  create: true %>
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

## Status

This repository is in the initial skeleton stage.
