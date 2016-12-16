class Thorax.Views.BaseFilterView extends Thorax.View
  setupSelect2: (elementSelector, url, placeholder) ->
    $(elementSelector).select2 {
      ajax:
        url: (params) ->
          return url + params.term
        dataType: 'json'
        delay: 500
        data: (params) ->
          return {}
        processResults: (data, params) ->
          autoData = $.map data, ( item ) ->
            return { text: (if item.name then item.name else item.display_name), id: (if item.id then item.id else item._id) }
          return { results: autoData, pagination: { more: false } }
        cache: true
      createTag: (params) ->
        # Disables new tags being allowed (we only want what's returned from the search)
        return undefined
      minimumInputLength: 2
      theme: "bootstrap"
      placeholder: placeholder
      tags: true
      minimumResultsForSearch: Infinity
    }

  setupTagIt: (elementSelector, placeholder) ->
    $(elementSelector).tagit {
      allowSpaces: true
      placeholderText: placeholder
      animate: false
      removeConfirmation: true
    }

  getSelect2Values: (elementSelector, fieldName) ->
    data = { field: fieldName, items: [] }
    $(elementSelector + " option:selected").each (index, item) ->
      data.items.push({id: item.value, text: item.text })
    return data
