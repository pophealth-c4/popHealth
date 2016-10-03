class Thorax.Views.FilterPatients extends Thorax.View
  template: JST['filters/filter_patients']

  context: ->
    currentRoute = Backbone.history.fragment
    _(super).extend
      titleSize: 3
      dataSize: 9
      token: $("meta[name='csrf-token']").attr('content')
      dialogTitle:  "Patient Filter"
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
      autocomplete:
        delay: 500
        minLength: 2
        source: ( request, response ) ->
          $.ajax
            url: url
            dataType: "json"
            success: ( data ) ->
              autoData = $.map data, ( item ) ->
                return { label: item.name, value: item.id }
              response autoData
    }

  setup: ->
    @filterPatientsDialog = @$("#filterPatientsDialog")
    @setupTag "#payerTags", "http://localhost:3000/api/value_sets"
    @setupTag "#raceTags", "http://localhost:3000/api/value_sets"
    @setupTag "#ethnicityTags", "http://localhost:3000/api/value_sets"
    @setupTag "#problemListTags", "http://localhost:3000/api/value_sets"
    @setupTag "#ageTags", null, "e.g. 18-25, >=30"

  display: ->
    @filterPatientsDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    @filterPatientsDialog.modal('hide')
