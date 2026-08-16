# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    private

    def rfk_choice_from_hash(selected)
      value = rfk_first_non_nil_hash_value(selected, :value, "value", :id, "id")
      label = rfk_first_non_nil_hash_value(selected, :text, "text", :label, "label", :name, "name")
      label = value if label.nil?

      [label, value]
    end

    def rfk_first_non_nil_hash_value(selected, *keys)
      keys.each do |key|
        next unless selected.key?(key)

        value = selected[key]
        return value unless value.nil?
      end

      nil
    end
  end
end
