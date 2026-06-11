# frozen_string_literal: true

require "json"

module RailsFieldsKit
  module FormBuilder
    TABLE_ADAPTER_METADATA_KEYS = %i[adapter param_name fields].freeze

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

    def rfk_password_field(method, **options)
      rfk_native_field(method, :password_field, **options)
    end

    def rfk_select(method, collection: nil, **options)
      rfk_tom_select_field(method, :select, collection: collection, **options)
    end

    def rfk_multi_select(method, collection: nil, **options)
      options[:multiple] = true unless options.key?(:multiple)
      rfk_tom_select_field(method, :multi_select, collection: collection, **options)
    end

    def rfk_grouped_select(method, grouped_collection:, **options)
      options[:grouped_collection] = grouped_collection
      rfk_tom_select_field(method, :select, collection: nil, **options)
    end

    def rfk_enum_select(method, enum: nil, **options)
      explicit_enum = !enum.nil?
      enum_values = explicit_enum ? enum : object.class.public_send(method.to_s.pluralize)
      collection = enum_values.keys.map { |key| [rfk_enum_label(method, key, explicit: explicit_enum), key] }
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

    def rfk_token_search(method, **options)
      options[:as] = :text unless options.key?(:as)
      options[:free_text] = true unless options.key?(:free_text)
      options[:create] = true unless options.key?(:create)
      options[:persist] = false unless options.key?(:persist)
      options[:delimiter] = " " unless options.key?(:delimiter)
      options[:plugins] = Array(options[:plugins]) | ["remove_button"] unless options.key?(:plugins)
      rfk_tom_select_field(method, :token_search, **options)
    end

    def rfk_table_filters(columns)
      @template.safe_join(RailsFieldsKit::TableMetadata.render_filters(self, columns))
    end

    def rfk_table_cell_editors(columns)
      @template.safe_join(RailsFieldsKit::TableMetadata.render_cell_editors(self, columns))
    end

    private

    def rfk_native_field(method, helper_name, **options)
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      field_options = options.merge(html_options)
      rfk_apply_accessibility!(method, field_options, wrapper_options)
      field_html = public_send(helper_name, method, field_options)
      field_html = rfk_wrap_control(field_html, wrapper_options)

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_tom_select_field(method, field_kind, collection: nil, **options)
      config = RailsFieldsKit.configuration
      wrapper_options = rfk_extract_wrapper_options(options)
      html_options = options.delete(:html) || {}
      rfk_promote_html_options!(options, html_options)
      rfk_strip_table_adapter_metadata!(options) if field_kind == :token_search
      rfk_apply_accessibility!(method, html_options, wrapper_options)
      data = html_options[:data] ||= {}
      data[:controller] = [data[:controller], config.controller_name].compact.join(" ")
      data[:rails_fields_kit__tom_select_kind_value] = field_kind

      grouped_collection = options.delete(:grouped_collection)
      disabled = options.delete(:disabled)
      option_html = options.delete(:option_html) || {}
      selected = options.delete(:selected)
      allow_clear = options.delete(:allow_clear)
      error_surface = options.delete(:error_surface)
      error_surface_html = options.delete(:error_surface_html) || {}
      value_method = options.delete(:value_method) || :id
      label_method = options.delete(:label_method) || :to_s
      collection_value_method = options.delete(:collection_value_method) || value_method
      collection_label_method = options.delete(:collection_label_method) || label_method
      selected_choices = rfk_normalize_selected(selected, value_method: value_method, label_method: label_method)
      plugins = rfk_option_or_default(options, :plugins, config.default_plugins)
      plugins = Array(plugins) | ["clear_button"] if allow_clear
      error_surface_id = rfk_error_surface_id(method, error_surface_html) if error_surface

      rfk_assign_data_value(data, :url, options.delete(:url))
      rfk_assign_data_value(data, :selected_url, options.delete(:selected_url))
      rfk_assign_data_value(data, :create_url, options.delete(:create_url))
      rfk_assign_data_value(data, :query_params, options.delete(:query_params))
      rfk_assign_data_value(data, :selected_query_params, options.delete(:selected_query_params))
      rfk_assign_data_value(data, :create_params, options.delete(:create_params))
      rfk_assign_data_value(data, :create, options.delete(:create))
      rfk_assign_data_value(data, :free_text, options.delete(:free_text))
      rfk_assign_data_value(data, :placeholder, options[:placeholder])
      rfk_assign_data_value(data, :query_param, rfk_option_or_default(options, :query_param, config.default_query_param))
      rfk_assign_data_value(data, :selected_param, rfk_option_or_default(options, :selected_param, config.default_selected_param))
      rfk_assign_data_value(data, :selected_multiple_param, rfk_option_or_default(options, :selected_multiple_param, config.default_selected_multiple_param))
      rfk_assign_data_value(data, :create_param, rfk_option_or_default(options, :create_param, config.default_create_param))
      rfk_assign_data_value(data, :value_field, rfk_option_or_default(options, :value_field, config.default_value_field))
      rfk_assign_data_value(data, :label_field, rfk_option_or_default(options, :label_field, config.default_label_field))
      rfk_assign_data_value(data, :search_field, rfk_option_or_default(options, :search_field, config.default_search_field))
      rfk_assign_data_value(data, :min_length, rfk_option_or_default(options, :min_length, config.default_min_length))
      rfk_assign_data_value(data, :max_options, rfk_option_or_default(options, :max_options, config.default_max_options))
      rfk_assign_data_value(data, :max_items, options.delete(:max_items))
      rfk_assign_data_value(data, :load_throttle, options.delete(:load_throttle))
      rfk_assign_data_value(data, :delimiter, options.delete(:delimiter))
      rfk_assign_data_value(data, :preload, rfk_option_or_default(options, :preload, config.default_preload))
      rfk_assign_data_value(data, :open_on_focus, rfk_option_or_default(options, :open_on_focus, config.default_open_on_focus))
      rfk_assign_data_value(data, :close_after_select, rfk_option_or_default(options, :close_after_select, config.default_close_after_select))
      rfk_assign_data_value(data, :hide_selected, rfk_option_or_default(options, :hide_selected, config.default_hide_selected))
      rfk_assign_data_value(data, :persist, rfk_option_or_default(options, :persist, config.default_persist))
      rfk_assign_data_value(data, :no_results_text, rfk_render_text_option(options, :no_results_text, config.default_no_results_text, "rails_fields_kit.tom_select.no_results_text", "No results found"))
      rfk_assign_data_value(data, :loading_text, rfk_render_text_option(options, :loading_text, config.default_loading_text, "rails_fields_kit.tom_select.loading_text", "Loading..."))
      rfk_assign_data_value(data, :create_text, rfk_render_text_option(options, :create_text, config.default_create_text, "Add"))
      rfk_assign_data_value(data, :option_description_field, rfk_option_or_default(options, :option_description_field, config.default_option_description_field))
      rfk_assign_data_value(data, :option_badge_field, rfk_option_or_default(options, :option_badge_field, config.default_option_badge_field))
      rfk_assign_data_value(data, :plugins, plugins)
      rfk_assign_data_value(data, :error_surface_id, error_surface_id) if error_surface
      rfk_apply_error_surface_accessibility!(html_options, error_surface_id) if error_surface

      html_options[:multiple] = options.delete(:multiple) if options.key?(:multiple)
      html_options[:placeholder] = options.delete(:placeholder) if options.key?(:placeholder)

      field_html = if field_kind == :autocomplete || html_options[:multiple] == false && options[:as] == :text || field_kind == :token_search
        text_field(method, options.merge(html_options).except(:as))
      elsif grouped_collection
        grouped_choices = rfk_normalize_grouped_collection(
          grouped_collection,
          value_method: collection_value_method,
          label_method: collection_label_method
        )
        options[:selected] ||= rfk_selected_values(selected_choices) if selected_choices.any?
        html_options[:disabled] = true if disabled == true
        grouped_options = @template.grouped_options_for_select(
          grouped_choices,
          rfk_grouped_option_selection(options[:selected], disabled)
        )
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
      field_html = rfk_append_error_surface(field_html, error_surface_id, error_surface_html) if error_surface

      rfk_wrap_field(method, field_html, wrapper_options)
    end

    def rfk_grouped_option_selection(selected, disabled)
      return selected if [nil, true, false].include?(disabled)

      disabled_values = Array(disabled).map(&:to_s)
      if selected.is_a?(Hash)
        selected.merge(disabled: Array(selected[:disabled] || selected["disabled"]).map(&:to_s) | disabled_values)
      elsif selected.nil?
        {disabled: disabled_values}
      else
        {selected: selected, disabled: disabled_values}
      end
    end

    def rfk_option_or_default(options, key, default)
      options.key?(key) ? options.delete(key) : default
    end

    def rfk_render_text_option(options, key, configured_default, i18n_key, fallback)
      value = options.key?(key) ? options.delete(key) : configured_default
      text = value.respond_to?(:call) ? value.call : value
      text = I18n.t(i18n_key, default: fallback) if text.nil?
      text
    end

    def rfk_assign_data_value(data, name, value)
      return if value.nil?

      key = "rails_fields_kit__tom_select_#{name}_value"
      data[key] = case value
      when Array, Hash
        JSON.generate(value)
      else
        value
      end
    end

    def rfk_choices_with_selected(collection, selected_choices:, value_method:, label_method:, disabled:, option_html: {})
      choices = collection || selected_choices
      normalized_disabled = Array(disabled).map(&:to_s)
      choices.map do |choice|
        value = rfk_option_value(choice, value_method)
        label = rfk_option_label(choice, label_method)
        html_options = option_html[value.to_s] || option_html[value] || {}
        html_options = html_options.merge(disabled: true) if normalized_disabled.include?(value.to_s)
        [label, value, html_options]
      end
    end

    def rfk_normalize_grouped_collection(grouped_collection, value_method:, label_method:)
      grouped_collection.map do |group_label, items|
        [group_label, rfk_choices_with_selected(items, selected_choices: [], value_method: value_method, label_method: label_method, disabled: nil)]
      end
    end

    def rfk_option_value(choice, value_method)
      if choice.respond_to?(value_method)
        choice.public_send(value_method)
      elsif choice.is_a?(Array)
        choice[1] || choice[0]
      else
        choice
      end
    end

    def rfk_option_label(choice, label_method)
      if choice.respond_to?(label_method) && !choice.is_a?(Array)
        choice.public_send(label_method)
      elsif choice.is_a?(Array)
        choice[0]
      else
        choice.to_s
      end
    end

    def rfk_normalize_selected(selected, value_method:, label_method:)
      Array(selected).compact.map do |choice|
        if choice.is_a?(Array)
          [choice[0], choice[1] || choice[0]]
        elsif choice.respond_to?(value_method)
          [rfk_option_label(choice, label_method), choice.public_send(value_method)]
        else
          [choice.to_s, choice]
        end
      end
    end

    def rfk_selected_values(selected_choices)
      selected_choices.map { |_label, value| value }
    end

    def rfk_extract_wrapper_options(options)
      wrapper_options = {}
      wrapper_options[:wrapper_class] = options.delete(:wrapper_class)
      wrapper_options[:label] = options.delete(:label)
      wrapper_options[:hint] = options.delete(:hint)
      wrapper_options[:error] = options.delete(:error)
      wrapper_options[:required] = options.delete(:required)
      wrapper_options
    end

    def rfk_apply_accessibility!(method, field_options, wrapper_options)
      describedby = []
      describedby << rfk_hint_id(method) if wrapper_options[:hint]
      describedby << rfk_error_id(method) if wrapper_options[:error]
      field_options[:aria] ||= {}
      field_options[:aria][:describedby] = describedby.join(" ") if describedby.any?
    end

    def rfk_apply_error_surface_accessibility!(html_options, error_surface_id)
      html_options[:aria] ||= {}
      html_options[:aria][:describedby] = [html_options[:aria][:describedby], error_surface_id].compact.join(" ")
    end

    def rfk_promote_html_options!(options, html_options)
      %i[class id data aria disabled required autofocus autocomplete inputmode min max step pattern placeholder multiple].each do |key|
        html_options[key] = options.delete(key) if options.key?(key)
      end
    end

    def rfk_error_surface_id(method, error_surface_html)
      error_surface_html[:id] || "#{@object_name}_#{method}_error_surface"
    end

    def rfk_wrap_field(method, field_html, options)
      classes = ["rfk-field", options[:wrapper_class]].compact.join(" ")
      label_html = options[:label] == false ? "" : label(method, options[:label])
      hint_html = options[:hint] ? @template.content_tag(:p, options[:hint], id: rfk_hint_id(method), class: "rfk-hint") : ""
      error_html = options[:error] ? @template.content_tag(:p, options[:error], id: rfk_error_id(method), class: "rfk-error") : ""

      @template.content_tag(:div, label_html.concat(field_html).concat(hint_html).concat(error_html), class: classes)
    end

    def rfk_wrap_control(field_html, options)
      @template.content_tag(:div, field_html, class: "rfk-control")
    end

    def rfk_hint_id(method)
      "#{@object_name}_#{method}_hint"
    end

    def rfk_error_id(method)
      "#{@object_name}_#{method}_error"
    end

    def rfk_strip_table_adapter_metadata!(options)
      TABLE_ADAPTER_METADATA_KEYS.each do |key|
        options.delete(key)
      end
    end
  end
end
