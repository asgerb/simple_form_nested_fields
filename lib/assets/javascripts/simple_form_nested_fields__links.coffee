do ($ = jQuery, window, document) ->
  pluginName = 'SimpleFormNestedFields__Links'
  defaults =
    debug: false
    new_item_class_name: 'simple_form_nested_fields__item--new'
    regexp: new RegExp("__INDEX_PLACEHOLDER__", 'g')

  class Plugin
    constructor: (@element, options) ->
      @options = $.extend {}, defaults, options
      @_defaults = defaults
      @_name = pluginName
      @$element = $(@element)
      @init()

    init: ->
      @$element.on "click.#{@_name}", '.simple_form_nested_fields__link', (e) =>
        e.preventDefault()
        e.stopImmediatePropagation()
        link = e.target
        switch
          when link.classList.contains('simple_form_nested_fields__link--add') then @add_new_item(link)
          when link.classList.contains('simple_form_nested_fields__link--remove') then @remove_item(link)

    destroy: ->
      @$element.off "click.#{@_name}", '.simple_form_nested_fields__link--add'

    get_index: -> new Date().getTime()
    get_item_class_name: -> @get_select().val()
    get_items_container: -> @$element.find('.simple_form_nested_fields__items')
    get_template: (link) ->
      item_class_name = @get_item_class_name()
      $template = @$element.find("template[data-class='#{item_class_name}']").first()
      $template.html().replace(@options.regexp, @get_index())
    get_select: -> @$element.find('.simple_form_nested_fields__select--add')

    add_new_item: (link) ->
      $template = $(@get_template(link))
      $template.addClass(@options.new_item_class_name)
      @get_items_container().append($template)

    remove_item: (link) ->
      $item = $(link).closest('.simple_form_nested_fields__item')
      if $item.hasClass(@options.new_item_class_name)
        $item.remove()
      else
        $item.find('input[type=hidden]').val('1')
        $item.hide()

  # A really lightweight plugin wrapper around the constructor,
  # preventing against multiple instantiations
  $.fn[pluginName] = (options) ->
    @each ->
      if !$.data(@, "plugin_#{pluginName}")
        $.data(@, "plugin_#{pluginName}", new Plugin(@, options))
