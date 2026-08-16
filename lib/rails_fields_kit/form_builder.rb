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

    def rfk_range_field(method, **options)
      rfk_native_field(method, :range_field, **options)
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
      rfk_tom_select_field(method, :grouped_select, collection: nil, **options)
    end

    def rfk_enum_select(method, enum: nil, **options)
      rendered_kind = Thread.current[:rails_fields_kit_render_table_cell_editor_metadata] ? :select : :enum_select
      explicit_enum = !enum.nil?
      enum_values = explicit_enum ? enum : object.class.public_send(method.to_s.pluralize)
      collection = enum_values.keys.map { |key| [rfk_enum_label(method, key, explicit: explicit_enum), key] }
      rfk_tom_select_field(method, rendered_kind, collection: collection, **options)
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

    def rfk_lookup(method, id_field:, **options)
      options[:free_text] = false unless options.key?(:free_text)
      options[:lookup_id_field] = id_field
      options[:selected] = object.public_send(id_field) unless options.key?(:selected) || !object.respond_to?(id_field)
      rfk_tom_select_field(method, :lookup, **options)
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
      table_filter_metadata = Thread.current[:rails_fields_kit_render_table_filter_metadata]
      table_adapter_metadata = rfk_extract_table_adapter_metadata!(options) if field_kind == :token_search
      rfk_apply_accessibility!(method, html_options, wrapper_options)
      data = html_options[:data] ||= {}
      data[:controller] = [data[:controller], config.controller_name].compact.join(" ")
      data[:rails_fields_kit__tom_select_kind_value] = field_kind
      rfk_assign_table_adapter_metadata!(data, table_adapter_metadata) if table_filter_metadata && table_adapter_metadata

      grouped_collection = options.delete(:grouped_collection)
      disabled = options.delete(:disabled)
      option_html = options.delete(:option_html) || {}
      selected = options.delete(:selected)
      lookup_id_field = options.delete(:lookup_id_field)
      clear_lookup_id_on_text_change = options.key?(:clear_id_on_text_change) ? options.delete(:clear_id_on_text_change) : true
      allow_clear = options.key?(:allow_clear) ? options.delete(:allow_clear) : config.default_allow_clear
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
      rfk_assign_data_value(data, :display_field, options.delete(:display_field))
      rfk_assign_data_value(data, :label_fallback, options.delete(:label_fallback))
      rfk_assign_data_value(data, :search_field, rfk_option_or_default(options, :search_field, config.default_search_field))
      rfk_assign_data_value(data, :min_length, rfk_option_or_default(options, :min_length, config.default_min_length))
      rfk_assign_data_value(data, :max_options, rfk_option_or_default(options, :max_options, config.default_max_options))
      rfk_assign_data_value(data, :max_items, options.delete(:max_items))
      rfk_assign_data_value(data, :load_throttle, rfk_option_or_default(options, :load_throttle, config.default_load_throttle))
      rfk_assign_data_value(data, :delimiter, options.delete(:delimiter))
      rfk_assign_data_value(data, :dropdown_parent, options.delete(:dropdown_parent))
      rfk_assign_data_value(data, :preload, rfk_option_or_default(options, :preload, config.default_preload))
      rfk_assign_data_value(data, :open_on_focus, rfk_option_or_default(options, :open_on_focus, config.default_open_on_focus))
      rfk_assign_data_value(data, :close_after_select, rfk_option_or_default(options, :close_after_select, config.default_close_after_select))
      rfk_assign_data_value(data, :hide_selected, rfk_option_or_default(options, :hide_selected, config.default_hide_selected))
      rfk_assign_data_value(data, :persist, rfk_option_or_default(options, :persist, config.default_persist))
      rfk_assign_data_value(data, :no_results_text, rfk_render_text_option(options, :no_results_text, config.default_no_results_text, "rails_fields_kit.tom_select.no_results_text", "No results found"))
      rfk_assign_data_value(data, :loading_text, rfk_render_text_option(options, :loading_text, config.default_loading_text, "rails_fields_kit.tom_select.loading_text", "Loading..."))
      rfk_assign_data_value(data, :create_text, rfk_render_text_option(options, :create_text, config.default_create_text, "rails_fields_kit.tom_select.create_text", "Add"))
      rfk_assign_data_value(data, :option_description_field, rfk_option_or_default(options, :option_description_field, config.default_option_description_field))
      rfk_assign_data_value(data, :option_badge_field, rfk_option_or_default(options, :option_badge_field, config.default_option_badge_field))
      rfk_assign_data_value(data, :option_metadata_fields, options.delete(:option_metadata_fields))
      rfk_assign_data_value(data, :plugins, plugins)
      rfk_assign_data_value(data, :error_surface_id, error_surface_id) if error_surface
      rfk_apply_error_surface_accessibility!(html_options, error_surface_id) if error_surface

      html_options[:multiple] = options.delete(:multiple) if options.key?(:multiple)
      html_options[:placeholder] = options.delete(:placeholder) if options.key?(:placeholder)

      field_html = if field_kind == :lookup
        text_hidden_id = field_id(method)
        id_hidden_id = field_id(lookup_id_field)
        lookup_control_id = "#{text_hidden_id}_lookup"
        text_value = object.public_send(method) if object.respond_to?(method)
        id_value = object.public_send(lookup_id_field) if object.respond_to?(lookup_id_field)
        wrapper_options[:label_html][:for] ||= lookup_control_id
        rfk_assign_data_value(data, :lookup_text_field_id, text_hidden_id)
        rfk_assign_data_value(data, :lookup_id_field_id, id_hidden_id)
        rfk_assign_data_value(data, :clear_lookup_id_on_text_change, clear_lookup_id_on_text_change)
        html_options[:id] = lookup_control_id
        html_options[:name] = nil
        html_options[:value] = id_value
        control = text_field(method, options.merge(html_options).except(:as))
        @template.safe_join([
          control,
          hidden_field(method, id: text_hidden_id, value: text_value),
          hidden_field(lookup_id_field, id: id_hidden_id, value: id_value)
        ])
      elsif field_kind == :autocomplete || html_options[:multiple] == false && options[:as] == :text || field_kind == :token_search
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
      return I18n.t(i18n_key, default: fallback) if rfk_bundled_render_text_default?(value)

      value
    end

    def rfk_bundled_render_text_default?(value)
      value == RailsFieldsKit::Configuration::DEFAULT_NO_RESULTS_TEXT ||
        value == RailsFieldsKit::Configuration::DEFAULT_LOADING_TEXT ||
        value == RailsFieldsKit::Configuration::DEFAULT_CREATE_TEXT
    end

    def rfk_promote_html_options!(options, html_options)
      %i[required readonly autocomplete].each do |key|
        html_options[key] = options.delete(key) if options.key?(key)
      end

      html_options[:disabled] = options.delete(:disabled) if [true, false].include?(options[:disabled])
    end

    def rfk_extract_table_adapter_metadata!(options)
      TABLE_ADAPTER_METADATA_KEYS.each_with_object({}) do |key, metadata|
        metadata[key] = options.delete(key) if options.key?(key)
        metadata[key] = options.delete(key.to_s) if options.key?(key.to_s)
      end
    end

    def rfk_assign_table_adapter_metadata!(data, metadata)
      adapter = metadata[:adapter]
      return if adapter.nil? || adapter.to_s.empty?

      rfk_assign_raw_data_value(data, :table_filter_adapter, adapter)
      rfk_assign_raw_data_value(data, :table_filter_param_name, metadata[:param_name])
      rfk_assign_raw_data_value(data, :table_filter_fields, metadata[:fields])
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
        suffix_html: options.delete(:suffix_html) || {},
        accessibility: options.key?(:accessibility) ? options.delete(:accessibility) : true
      }
    end

    def rfk_apply_accessibility!(method, html_options, wrapper_options)
      return unless wrapper_options[:wrapper] && wrapper_options[:accessibility]

      described_by = []
      described_by << rfk_hint_id(method) if wrapper_options[:hint]
      errors = rfk_errors_for(method)
      described_by << rfk_error_id(method) if errors.any?
      html_options[:aria] ||= {}
      existing_described_by = html_options[:aria][:describedby] || html_options[:aria]["describedby"]
      described_by.unshift(existing_described_by) if existing_described_by
      html_options[:aria].delete("describedby")
      html_options[:aria][:describedby] = described_by.join(" ") if described_by.any?
      html_options[:aria][:invalid] = true if errors.any?
      html_options[:aria][:required] = true if html_options[:required]
    end

    def rfk_apply_error_surface_accessibility!(html_options, error_surface_id)
      html_options[:aria] ||= {}
      existing_described_by = html_options[:aria][:describedby] || html_options[:aria]["describedby"]
      described_by = Array(existing_described_by.to_s.split(/\s+/)).reject(&:empty?)
      described_by << error_surface_id unless described_by.include?(error_surface_id)
      html_options[:aria].delete("describedby")
      html_options[:aria][:describedby] = described_by.join(" ")
    end

    def rfk_hint_id(method)
      "#{object_name}_#{method}_hint"
    end

    def rfk_error_id(method)
      "#{object_name}_#{method}_error"
    end

    def rfk_error_surface_id(method, error_surface_html = {})
      explicit_id = error_surface_html[:id] || error_surface_html["id"]
      return explicit_id unless explicit_id.nil? || explicit_id.to_s.empty?

      "#{object_name}_#{method}_error_surface"
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

    def rfk_append_error_surface(field_html, error_surface_id, error_surface_html)
      surface_options = error_surface_html.dup
      surface_options[:id] = error_surface_id
      surface_options.delete("id")
      surface_options[:hidden] = true unless surface_options.key?(:hidden)
      surface_options[:role] ||= "status"
      surface_options[:"aria-live"] ||= "polite"
      surface_options[:"aria-atomic"] = true unless surface_options.key?(:"aria-atomic")
      surface_options[:class] = [surface_options[:class], "rfk-tom-select-error-surface"].compact.join(" ")

      @template.safe_join([field_html, @template.content_tag(:div, "", surface_options)])
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
        parts << rfk_hint(method, wrapper_options[:hint], wrapper_options[:hint_html]) if wrapper_options[:hint]
        parts << rfk_error(method, errors, wrapper_options[:error_html]) if errors.any?
        parts.join.html_safe
      end
    end

    def rfk_label(method, label_text, label_html)
      label_options = label_html.dup
      label_options[:class] = [label_options[:class], RailsFieldsKit.configuration.label_class].compact.join(" ")
      label(method, label_text, label_options)
    end

    def rfk_hint(method, hint, hint_html)
      hint_options = hint_html.dup
      hint_options[:id] ||= rfk_hint_id(method)
      hint_options[:class] = [hint_options[:class], RailsFieldsKit.configuration.hint_class].compact.join(" ")
      @template.content_tag(:div, hint, hint_options)
    end

    def rfk_error(method, errors, error_html)
      error_options = error_html.dup
      error_options[:id] ||= rfk_error_id(method)
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
      data[data_key] = (value.is_a?(Array) || value.is_a?(Hash)) ? JSON.generate(value) : value
    end

    def rfk_assign_raw_data_value(data, key, value)
      return if value.nil?
      return if value.respond_to?(:empty?) && value.empty?

      data_key = "rails_fields_kit_#{key}"
      data[data_key] = (value.is_a?(Array) || value.is_a?(Hash)) ? JSON.generate(value) : value
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
          (item.is_a?(Array) && item.size == 2) ? [item] : rfk_normalize_selected(item, value_method: value_method, label_method: label_method)
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

    def rfk_enum_label(method, value, explicit: false)
      return value.to_s.humanize if explicit && !object.class.respond_to?(:human_attribute_name)

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
