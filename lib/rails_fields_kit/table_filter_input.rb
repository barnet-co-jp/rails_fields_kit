# frozen_string_literal: true

module RailsFieldsKit
  class TableFilterInput
    attr_reader :field_type, :field_name, :options

    def initialize(field_type = nil, field_name = nil, type: nil, **options)
      @field_type = (field_type || type || :combobox).to_sym
      @field_name = field_name&.to_s
      @options = options
    end

    def to_table_filter
      {
        type: "rails_fields_kit",
        field_type: field_type.to_s,
        method: field_name,
        options: options.dup
      }.compact
    end
  end
end
