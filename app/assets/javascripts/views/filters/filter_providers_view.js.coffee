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

  setupTag: (elementSelector, url, placeholder) ->
    $(elementSelector).tagit {
      showAutocompleteOnFocus: true
      allowSpaces: true
      placeholderText: placeholder
      animate: false
      removeConfirmation: true
      autocomplete:
        delay: 500
        minLength: 2
        source: ( request, response ) ->
          $.ajax
            url: url + request.term
            dataType: "json"
            success: ( data ) ->
              autoData = $.map data, ( item ) ->
                return { label: (if item.name then item.name else item.display_name), value: (if item.id then item.id else item._id) }
              response autoData
    }

  setup: ->
    @filterProvidersDialog = @$("#filterProvidersDialog")
    @setupTag "#npiTags", "http://localhost:3000/api/providers/search?npi="
    @setupTag "#tinTags", "http://localhost:3000/api/practices/search?tin="
    @setupTag "#providerTypeTags", "http://localhost:3000/api/value_sets/2.16.840.1.113762.1.4.1026.23.json?search="
    @setupTag "#addressTags", "http://localhost:3000/api/practices/search?address="

  display: ->
    @filterProvidersDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    @filterProvidersDialog.modal('hide')
