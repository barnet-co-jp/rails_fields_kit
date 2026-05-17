# frozen_string_literal: true

require "json"

module RailsFieldsKit
  module FormBuilder
    def rfk_text_field(method, **options)
      rfk_native_field(method, :text_field, **options)
    end

    def rfk_text_area(method, **options)
      rfk_native_field(method, :text_area, **options)
    end

    def rfk_number_field(method, **options)
      rfk_native_field(method, :number_field, **options)
    end

    def rfk_money_field(method, currency: nil, **options)
      options[:inputmode] ||= "decimal"
      options[:prefix] = currency if currency
      rfk_native_field(method, :text_field, **options)
    end

    def rfk_percent_field(method, **options)
      options[:inputmode] ||= "decimal"
      options[:suffix] = "%" unless options.key?(:suffix)
      rfk_native_field(method, :number_field, **options)
    end

    def rfk_email_field(method, **options)
      rfk_native_field(method, :email_field, **options)
    end

    def rfk_url_field(method, **options)
      rfk_native_field(method, :url_field, **options)
    end

    def rfk_phone_field(method, **options)
      options[:autocomplete] ||= "tel"
      rfk_native_field(method, :telephone_field, **options)
    end

    def rfk_search_field(method, **options)
      rfk_native_field(method, :search_field, **options)
    end

    def rfk_select(method, collection: nil, **options)
      rfk_tom_select_field(method, :select, collection: collection, **options)
    end

    def rfk_grouped_select(method, grouped_collection:, **options)
      options[:grouped_collection] = grouped_collection
      rfk_tom_select_field(method, :select, collection: nil, **options)
    end

    def rfk_enum_select(method, enum: nil, **options)
      enum_values = enum || object.class.public_send(method.to_s.pluralize)
      collection = enum_values.keys.map { |key| [rfk_enum_label(method, key), key] }
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

    def rfk_native_field(method, helper_name, **options)
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      field_options = options.merge(html_options)
      field_html = public_send(helper_name, method, field_options)
      field_html = rfk_wrap_control(field_html, wrapper_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      config = RailsFieldsKit.configuration
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      data = html_options[:data] ||= {}
      data[:controller] = [data[:controller], config.controller_name].compact.join(" ")
      data[:rails_fields_kit__tom_select_kind_value] = field_kind

      grouped_collection = options.delete(:grouped_collection)
      disabled = options.delete(:disabled)
      option_html = options.delete(:option_html) || {}
      selected = options.delete(:selected)
      allow_clear = options.delete(:allow_clear)
      value_method = options.delete(:value_method) || :id
      label_method = options.delete(:label_method) || :to_s
      collection_value_method = options.delete(:collection_value_method) || value_method
      collection_label_method = options.delete(:collection_label_method) || label_method
      selected_choices = rfk_normalize_selected(selected, value_method: value_method, label_method: label_method)
      plugins = options.delete(:plugins) || config.default_plugins
      plugins = Array(plugins) | ["clear_button"] if allow_clear

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
      rfk_assign_data_value(data, :max_options, options.delete(:max_options) || config.default_max_options)
      rfk_assign_data_value(data, :preload, options.delete(:preload) || config.default_preload)
      rfk_assign_data_value(data, :open_on_focus, options.delete(:open_on_focus) || config.default_open_on_focus)
      rfk_assign_data_value(data, :close_after_select, options.delete(:close_after_select) || config.default_close_after_select)
      rfk_assign_data_value(data, :hide_selected, options.delete(:hide_selected) || config.default_hide_selected)
      rfk_assign_data_value(data, :persist, options.delete(:persist) || config.default_persist)
      rfk_assign_data_value(data, :no_results_text, options.delete(:no_results_text) || config.default_no_results_text)
      rfk_assign_data_value(data, :loading_text, options.delete(:loading_text) || config.default_loading_text)
      rfk_assign_data_value(data, :create_text, options.delete(:create_text) || config.default_create_text)
      rfk_assign_data_value(data, :option_description_field, options.delete(:option_description_field) || config.default_option_description_field)
      rfk_assign_data_value(data, :option_badge_field, options.delete(:option_badge_field) || config.default_option_badge_field)
      rfk_assign_data_value(data, :plugins, plugins)

      html_options[:multiple] = options.delete(:multiple) if options.key?(:multiple)
      html_options[:placeholder] = options.delete(:placeholder) if options.key?(:placeholder)

      field_html = if field_kind == :autocomplete || html_options[:multiple] == false && options[:as] == :text
        text_field(method, options.merge(html_options))
      elsif grouped_collection
        grouped_choices = rfk_normalize_grouped_collection(
          grouped_collection,
          value_method: collection_value_method,
          label_method: collection_label_method
        )
        options[:selected] ||= rfk_selected_values(selected_choices) if selected_choices.any?
        grouped_options = @template.grouped_options_for_select(grouped_choices, options[:selected])
        select(method, grouped_options, options.except(:selected), html_options)
      else
        choices = rfk_choices_with_selected(
          collection,
          selected_choices: selected_choices,
          value_method: collection_value_method,
          label_method: collection_label_method,
          disabled: disabled,
          option_html: option_html
        )
        options[:selected] ||= rfk_selected_values(selected_choices) if selected_choices.any?
        select(method, choices, options, html_options)
      end
      field_html = rfk_wrap_control(field_html, wrapper_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_extract_wrapper_options(options)
      {
        label: options.delete(:label),
        hint: options.delete(:hint),
        prefix: options.delete(:prefix),
        suffix: options.delete(:suffix),
        wrapper: options.key?(:wrapper) ? options.delete(:wrapper) : false,
        wrapper_html: options.delete(:wrapper_html) || {},
        label_html: options.delete(:label_html) || {},
        hint_html: options.delete(:hint_html) || {},
        error_html: options.delete(:error_html) || {},
        control_html: options.delete(:control_html) || {},
        prefix_html: options.delete(:prefix_html) || {},
        suffix_html: options.delete(:suffix_html) || {}
      }
    end

    def rfk_wrap_control(field_html, wrapper_options)
      return field_html unless wrapper_options[:prefix] || wrapper_options[:suffix]

      config = RailsFieldsKit.configuration
      control_html = wrapper_options[:control_html].dup
      control_html[:class] = [control_html[:class], config.control_class].compact.join(" ")

      @template.content_tag(:div, control_html) do
        parts = []
        parts << rfk_affix(wrapper_options[:prefix], wrapper_options[:prefix_html], config.prefix_class) if wrapper_options[:prefix]
        parts << field_html
        parts << rfk_affix(wrapper_options[:suffix], wrapper_options[:suffix_html], config.suffix_class) if wrapper_options[:suffix]
        parts.join.html_safe
      end
    end

    def rfk_affix(content, html_options, default_class)
      options = html_options.dup
      options[:class] = [options[:class], default_class].compact.join(" ")
      @template.content_tag(:span, content, options)
    end

    def rfk_wrap_field(method, field_html, wrapper_options)
      return field_html unless wrapper_options[:wrapper]

      config = RailsFieldsKit.configuration
      errors = rfk_errors_for(method)
      wrapper_html = wrapper_options[:wrapper_html].dup
      wrapper_html[:class] = [wrapper_html[:class], config.wrapper_class, (config.field_error_class if errors.any?)].compact.join(" ")

      @template.content_tag(:div, wrapper_html) do
        parts = []
        parts << rfk_label(method, wrapper_options[:label], wrapper_options[:label_html]) unless wrapper_options[:label] == false
        parts << field_html
        parts << rfk_hint(wrapper_options[:hint], wrapper_options[:hint_html]) if wrapper_options[:hint]
        parts << rfk_error(errors, wrapper_options[:error_html]) if errors.any?
        parts.join.html_safe
      end
    end

    def rfk_label(method, label_text, label_html)
      label_options = label_html.dup
      label_options[:class] = [label_options[:class], RailsFieldsKit.configuration.label_class].compact.join(" ")
      label(method, label_text, label_options)
    end

    def rfk_hint(hint, hint_html)
      hint_options = hint_html.dup
      hint_options[:class] = [hint_options[:class], RailsFieldsKit.configuration.hint_class].compact.join(" ")
      @template.content_tag(:div, hint, hint_options)
    end

    def rfk_error(errors, error_html)
      error_options = error_html.dup
      error_options[:class] = [error_options[:class], RailsFieldsKit.configuration.error_class].compact.join(" ")
      @template.content_tag(:div, errors.join(", "), error_options)
    end

    def rfk_errors_for(method)
      return [] unless object.respond_to?(:errors) && object.errors.respond_to?(:[])

      Array(object.errors[method]).map(&:to_s).reject(&:empty?)
    end

    def rfk_assign_data_value(data, key, value)
      return if value.nil?
      return if value.respond_to?(:empty?) && value.empty?

      data_key = "rails_fields_kit__tom_select_#{key}_value"
      data[data_key] = value.is_a?(Array) || value.is_a?(Hash) ? JSON.generate(value) : value
    end

    def rfk_choices_with_selected(collection, selected_choices:, value_method:, label_method:, disabled: nil, option_html: {})
      choices = rfk_normalize_collection(collection, value_method: value_method, label_method: label_method, disabled: disabled, option_html: option_html)
      existing_values = choices.map { |choice| Array(choice).second.to_s }
      missing_selected_choices = selected_choices.reject { |choice| existing_values.include?(choice.second.to_s) }

      missing_selected_choices + choices
    end

    def rfk_selected_values(selected_choices)
      selected_choices.map(&:second)
    end

    def rfk_normalize_collection(collection, value_method:, label_method:, disabled: nil, option_html: {})
      disabled_values = Array(disabled).map(&:to_s)

      case collection
      when nil
        []
      when Hash
        collection.map { |label, value| rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html) }
      else
        collection.map do |item|
          if item.is_a?(Array) && item.size == 2
            rfk_choice_with_html(item.first, item.second, disabled_values: disabled_values, option_html: option_html)
          else
            value = rfk_read_selected_value(item, value_method)
            label = rfk_read_selected_label(item, label_method)
            rfk_choice_with_html(label, value, disabled_values: disabled_values, option_html: option_html)
          end
        end
      end
    end

    def rfk_choice_with_html(label, value, disabled_values:, option_html:)
      html = rfk_option_html_for(value, option_html)
      html[:disabled] = true if disabled_values.include?(value.to_s)
      html.empty? ? [label, value] : [label, value, html]
    end

    def rfk_option_html_for(value, option_html)
      case option_html
      when Proc
        option_html.call(value) || {}
      when Hash
        option_html[value] || option_html[value.to_s] || {}
      else
        {}
      end
    end

    def rfk_normalize_grouped_collection(grouped_collection, value_method:, label_method:)
      grouped_collection.map do |group_label, items|
        [group_label, rfk_normalize_collection(items, value_method: value_method, label_method: label_method)]
      end
    end

    def rfk_normalize_selected(selected, value_method:, label_method:)
      case selected
      when nil
        []
      when Hash
        [rfk_choice_from_hash(selected)]
      when Array
        selected.flat_map do |item|
          item.is_a?(Array) && item.size == 2 ? [item] : rfk_normalize_selected(item, value_method: value_method, label_method: label_method)
        end
      else
        [[rfk_read_selected_label(selected, label_method), rfk_read_selected_value(selected, value_method)]]
      end
    end

    def rfk_choice_from_hash(selected)
      value = selected[:value] || selected["value"] || selected[:id] || selected["id"]
      label = selected[:text] || selected["text"] || selected[:label] || selected["label"] || selected[:name] || selected["name"] || value

      [label, value]
    end

    def rfk_enum_label(method, value)
      object.class.human_attribute_name("#{method}.#{value}", default: value.to_s.humanize)
    end

    def rfk_read_selected_value(record, value_method)
      record.respond_to?(value_method) ? record.public_send(value_method) : record
    end

    def rfk_read_selected_label(record, label_method)
      record.respond_to?(label_method) ? record.public_send(label_method) : record.to_s
    end
  end
end
