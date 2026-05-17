# frozen_string_literal: true

require "json"

module RailsFieldsKit
  module FormBuilder
    def rfk_select(method, collection: nil, **options)
      rfk_tom_select_field(method, :select, collection: collection, **options)
    end

    def rfk_combobox(method, collection: nil, **options)
      rfk_tom_select_field(method, :combobox, collection: collection, **options)
    end

    def rfk_tags(method, collection: nil, **options)
      options[:multiple] = true unless options.key?(:multiple)
      options[:plugins] = Array(options[:plugins]) | ["remove_button"] unless options.key?(:plugins)
      rfk_tom_select_field(method, :tags, collection: collection, **options)
    end

    def rfk_autocomplete(method, **options)
      options[:free_text] = true unless options.key?(:free_text)
      rfk_tom_select_field(method, :autocomplete, **options)
    end

    private

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      config = RailsFieldsKit.configuration
      html_options = options.delete(:html) || {}
      data = html_options[:data] ||= {}
      data[:controller] = [data[:controller], config.controller_name].compact.join(" ")
      data[:rails_fields_kit__tom_select_kind_value] = field_kind

      rfk_assign_data_value(data, :url, options.delete(:url))
      rfk_assign_data_value(data, :create_url, options.delete(:create_url))
      rfk_assign_data_value(data, :create, options.delete(:create))
      rfk_assign_data_value(data, :free_text, options.delete(:free_text))
      rfk_assign_data_value(data, :placeholder, options[:placeholder])
      rfk_assign_data_value(data, :query_param, options.delete(:query_param) || config.default_query_param)
      rfk_assign_data_value(data, :create_param, options.delete(:create_param) || config.default_create_param)
      rfk_assign_data_value(data, :value_field, options.delete(:value_field) || config.default_value_field)
      rfk_assign_data_value(data, :label_field, options.delete(:label_field) || config.default_label_field)
      rfk_assign_data_value(data, :search_field, options.delete(:search_field) || config.default_search_field)
      rfk_assign_data_value(data, :min_length, options.delete(:min_length) || config.default_min_length)
      rfk_assign_data_value(data, :plugins, options.delete(:plugins) || config.default_plugins)

      html_options[:multiple] = options.delete(:multiple) if options.key?(:multiple)
      html_options[:placeholder] = options.delete(:placeholder) if options.key?(:placeholder)

      if field_kind == :autocomplete || html_options[:multiple] == false && options[:as] == :text
        text_field(method, options.merge(html_options))
      else
        choices = rfk_normalize_collection(collection)
        select(method, choices, options, html_options)
      end
    end

    def rfk_assign_data_value(data, key, value)
      return if value.nil?
      return if value.respond_to?(:empty?) && value.empty?

      data_key = "rails_fields_kit__tom_select_#{key}_value"
      data[data_key] = value.is_a?(Array) || value.is_a?(Hash) ? JSON.generate(value) : value
    end

    def rfk_normalize_collection(collection)
      case collection
      when nil
        []
      when Hash
        collection.map { |label, value| [label, value] }
      else
        collection
      end
    end
  end
end
