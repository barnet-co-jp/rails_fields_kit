# frozen_string_literal: true

module RailsFieldsKit
  class TableFilterInput
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
      range_field
      date_field
      time_field
      datetime_local_field
      color_field
      money_field
      percent_field
      email_field
      url_field
      phone_field
      search_field
      password_field
      check_box
      radio_button
    ].freeze

    KNOWN_FIELD_TYPES = (COMMON_FIELD_TYPES + %i[token_search lookup]).freeze

    attr_reader :field_type

    class << self
      COMMON_FIELD_TYPES.each do |field_type|
        define_method(field_type) do |field_name = nil, **options|
          from_type(field_type, field_name, **options)
        end
      end

      def from_type(field_type, field_name = nil, **options)
        new(field_type, field_name, **options)
      end

      def known_types
        KNOWN_FIELD_TYPES.dup
      end

      def known_type?(field_type)
        normalized_field_type = field_type.to_s.strip
        return false if normalized_field_type.empty?

        KNOWN_FIELD_TYPES.include?(normalized_field_type.to_sym)
      end

      def token_search(field_name = :query, url: nil, **options)
        filter_options = options.dup
        filter_options[:url] = url if url
        from_type(:token_search, field_name, **filter_options)
      end

      def ransack_filter(field_name = :query, fields:, url: nil, param_name: :q, **options)
        filter_options = {
          adapter: :ransack,
          param_name: param_name,
          fields: fields
        }.merge(options)
        filter_options[:url] = url if url
        from_type(:token_search, field_name, **filter_options)
      end

      def lookup(field_name, id_field:, **options)
        filter_options = options.merge(id_field: id_field)
        from_type(:lookup, field_name, **filter_options)
      end
    end

    def initialize(field_type = nil, field_name = nil, type: nil, **options)
      @field_type = (field_type || type || :combobox).to_sym
      @field_name = field_name&.to_s
      @options = options
    end

    def field_name
      @field_name&.dup
    end

    def options
      @options.dup
    end

    def to_table_filter
      to_h
    end

    def to_hash
      to_h
    end

    def to_h
      {
        type: "rails_fields_kit",
        field_type: field_type.to_s,
        method: field_name,
        options: options
      }.compact
    end
  end
end
