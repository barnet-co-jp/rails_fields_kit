# frozen_string_literal: true

RSpec.describe RailsFieldsKit::TableMetadata do
  ExplicitFalseFilterColumn = Struct.new(:filter, :filter_input, keyword_init: true)
  ExplicitFalseEditorColumn = Struct.new(:editor, :cell_editor, keyword_init: true)

  it "treats explicit false object filter metadata as disabled metadata" do
    column = ExplicitFalseFilterColumn.new(
      filter: false,
      filter_input: RailsFieldsKit::TableFilterInput.combobox(:customer_id, url: "/customers.json")
    )

    expect(described_class.filters([column])).to eq([])
    expect(described_class.filter_calls([column])).to eq([])
  end

  it "treats explicit false object cell editor metadata as disabled metadata" do
    column = ExplicitFalseEditorColumn.new(
      editor: false,
      cell_editor: RailsFieldsKit::TableCellInput.enum_select(:status)
    )

    expect(described_class.cell_editors([column])).to eq([])
    expect(described_class.cell_editor_calls([column])).to eq([])
  end
end
