class Thorax.Views.FilterProviders extends Thorax.View
  template: JST['filters/filter_providers']

  context: ->
    currentRoute = Backbone.history.fragment
    _(super).extend
      titleSize: 3
      dataSize: 9
      token: $("meta[name='csrf-token']").attr('content')
      dialogTitle:  "Provider Filter"
      isUpdate: @model?
      showLoadInformation: true
      measureTypeLabel: null
      calculationTypeLabel: null
      hqmfSetId: null
      redirectRoute: currentRoute

  events:
    'ready': 'setup'
    'click #save_and_run': 'submit'

  setupSelect: (elementSelector, fieldName, url, placeholder) ->
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

  setup: ->
    @filterProvidersDialog = @$("#filterProvidersDialog")
    @setupSelect "#npiTags", "npi", "api/providers/search?npi="
    @setupSelect "#tinTags", "tin", "api/practices/search?tin="
    @setupSelect "#providerTypeTags", "providerType", "api/value_sets/2.16.840.1.113762.1.4.1026.23.json?search="
    @setupSelect "#addressTags", "address", "api/practices/search?address="

  display: ->
    @filterProvidersDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    @filterProvidersDialog.modal('hide')
    @trigger('filterSaved')
