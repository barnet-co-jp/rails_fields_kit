# frozen_string_literal: true

RSpec.describe "table direct helper boundary" do
  class DirectTableHelperTemplate
    attr_reader :joined_parts

    def safe_join(parts)
      @joined_parts = parts
      parts.join("\n")
    end
  end

  class DirectTableHelperBuilder
    include RailsFieldsKit::FormBuilder

    def initialize(template)
      @template = template
    end

    def rfk_text_field(method, **options)
      "text:#{method}:#{options[:placeholder]}"
    end

    def rfk_email_field(method, **options)
      "email:#{method}:#{options[:placeholder]}"
    end
  end

  def builder_with_template
    template = DirectTableHelperTemplate.new
    [DirectTableHelperBuilder.new(template), template]
  end

  it "safe-joins table filter render output without owning batch wrapping" do
    builder, template = builder_with_template
    columns = [
      {
        filter: {
          field_type: :text_field,
          method: :keyword,
          options: { placeholder: "Search orders" }
        }
      }
    ]

    html = builder.rfk_table_filters(columns)

    expect(html).to eq("text:keyword:Search orders")
    expect(template.joined_parts).to eq(["text:keyword:Search orders"])
  end

  it "safe-joins table cell editor render output without owning batch wrapping" do
    builder, template = builder_with_template
    columns = [
      {
        editor: {
          field_type: :email_field,
          method: :contact_email,
          options: { placeholder: "user@example.com" }
        }
      }
    ]

    html = builder.rfk_table_cell_editors(columns)

    expect(html).to eq("email:contact_email:user@example.com")
    expect(template.joined_parts).to eq(["email:contact_email:user@example.com"])
  end

  it "keeps direct table helpers limited to the columns argument" do
    builder, = builder_with_template

    expect { builder.rfk_table_filters([], wrapper_html: {}) }.to raise_error(ArgumentError)
    expect { builder.rfk_table_cell_editors([], item_html: {}) }.to raise_error(ArgumentError)
  end
end
