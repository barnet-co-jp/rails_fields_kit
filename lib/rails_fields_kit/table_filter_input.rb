# frozen_string_literal: true

module RailsFieldsKit
  class TableFilterInput
    attr_reader :field_type, :method, :options

    def initialize(field_type = nil, method = nil, type: nil, **options)
      @field_type = (field_type || type || :combobox).to_sym
      @method = method&.to_s
      @options = options
    end

    def to_table_filter
      {
        type: "rails_fields_kit",
        field_type: field_type.to_s,
        method: method,
        options: options
      }.compact
    end
  end
end
