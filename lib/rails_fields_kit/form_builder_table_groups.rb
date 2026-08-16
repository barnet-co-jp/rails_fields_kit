# frozen_string_literal: true

module RailsFieldsKit
  module FormBuilder
    def rfk_table_filters(columns, group_html: nil)
      rfk_wrap_table_group(
        @template.safe_join(RailsFieldsKit::TableMetadata.render_filters(self, columns)),
        group_html
      )
    end

    def rfk_table_cell_editors(columns, group_html: nil)
      rfk_wrap_table_group(
        @template.safe_join(RailsFieldsKit::TableMetadata.render_cell_editors(self, columns)),
        group_html
      )
    end

    private

    def rfk_wrap_table_group(rendered_html, group_html)
      return rendered_html unless group_html

      @template.content_tag(:div, rendered_html, group_html)
    end
  end
end
