# frozen_string_literal: true

module RailsFieldsKit
  class TableCellInput
    COMMON_FIELD_TYPES = %i[
      select
      combobox
      autocomplete
      tags
      multi_select
      grouped_select
      enum_select
      text_field
      text_area
      number_field
      money_field
      percent_field
      email_field
      url_field
      phone_field
      search_field
      token_search
    ].freeze

    attr_reader :field_type, :field_name, :options

    class << self
      COMMON_FIELD_TYPES.each do |field_type|
        define_method(field_type) do |field_name = nil, **options|
          from_type(field_type, field_name, **options)
        end
      end

      def from_type(field_type, field_name = nil, **options)
        new(field_type, field_name, **options)
      end
    end

    def initialize(field_type = nil, field_name = nil, type: nil, **options)
      @field_type = (field_type || type || :combobox).to_sym
      @field_name = field_name&.to_s
      @options = options
    end

    def to_table_cell_editor
      {
        type: "rails_fields_kit",
        field_type: field_type.to_s,
        method: field_name,
        options: options.dup
      }.compact
    end
  end
end