module SimpleFormNestedFields
  class NestedFieldsBuilder
    extend Forwardable

    BASE_DOM_CLASS = 'simple_form_nested_fields'.freeze
    CHILD_INDEX_STRING = '__INDEX_PLACEHOLDER__'.freeze

    attr_accessor :builder, :template, :record_name, :record_object, :options

    def initialize(builder, template, record_name, record_object, options = {})
      @builder = builder
      @template = template
      @record_name = record_name
      @record_object = record_object
      @options = options
    end

    def_delegators :builder, :object, :object_name, :simple_fields_for
    def_delegators :template, :concat, :content_tag, :hidden_field_tag, :link_to, :render

    def nested_fields_for
      dom_class = [bem_class, bem_class(m: record_name)]
      dom_class << bem_class(m: :sortable) if is_sortable?

      content_tag(:div, class: dom_class) do
        concat nested_fields_title
        concat nested_fields_items
        concat nested_fields_links
      end
    end

    private

    def is_sortable?
      options[:sortable] == true
    end

    def partial_path
      File.join(object.model_name.collection, relation.klass.model_name.collection, 'fields')
    end

    def relation
      object.reflect_on_association(record_name)
    end

    def nested_fields_title
      # dom_class = Bem.bem(:modulor_nested_fields, :title)
      dom_class = bem_class(e: :title)
      title = relation.klass.model_name.human.pluralize
      content_tag(:div, title, class: dom_class).html_safe
    end

    def nested_fields_items
      content_tag(:div, class: bem_class(e: :items)) do
        simple_fields_for(record_name, record_object, options) do |fields|
          dom_class = bem_class(e: :item, m: relation.klass)
          dom_data = { id: fields.object.id.to_s }

          content_tag(:div, class: dom_class, data: dom_data) do
            concat nested_fields_item_handle
            concat render(partial_path, fields: fields)
            concat link_to_remove(fields)
          end
        end
      end
    end

    def nested_fields_links
      # dom_class = 'simple_form_nested_fields__links'
      dom_class = bem_class(e: :links)
      content_tag(:div, link_to_add, class: dom_class).html_safe
    end

    def link_to_add
      label = options.fetch(:label_add, ::I18n.t(:add, scope: %i[simple_form_nested_fields links], model_name: relation.klass.model_name.human))
      dom_class = [bem_class(e: :link), bem_class(e: :link, m: :add)]
      dom_data = { template: CGI.escapeHTML(nested_fields_template).html_safe, turbolinks: 'false' }
      link_to(label, '#', class: dom_class, data: dom_data).html_safe
    end

    def nested_fields_item_handle
      return unless is_sortable?
      # dom_class = 'simple_form_nested_fields__item_handle'
      dom_class = bem_class(e: :item_handle)
      content_tag(:div, nil, class: dom_class).html_safe
    end

    def nested_fields_template
      dom_class = bem_class(e: :item, m: relation.klass)
      content_tag :div, nested_fields_template_string, class: dom_class
    end

    def nested_fields_template_string
      simple_fields_for(record_name, relation.klass.new, child_index: CHILD_INDEX_STRING) do |fields|
        nested_fields_item_handle.to_s.html_safe +
          render(partial_path, fields: fields).html_safe +
          link_to_remove(fields)
      end.html_safe
    end

    def destroy_field_tag(fields)
      return if fields.object.new_record?
      hidden_field_tag("#{fields.object_name}[_destroy]", fields.object._destroy).html_safe
    end

    def link_to_remove(fields, options = {})
      label = options.fetch(:label, ::I18n.t(:remove, scope: %i[simple_form_nested_fields links]))
      dom_class = [bem_class(e: :link), bem_class(e: :link, m: :remove)]
      dom_data = { turbolinks: 'false' }
      [
        destroy_field_tag(fields),
        link_to(label, '#', class: dom_class, data: dom_data)
      ].reject(&:blank?).join.html_safe
    end

    def bem_class(e: nil, m: nil)
      res = [BASE_DOM_CLASS]
      res << "__#{e}" if e.present?
      res << "__#{m}" if m.present?
      res.join
    end
  end
end
