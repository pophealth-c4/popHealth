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
    'click #save_and_run': 'submit'
   
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
                return { label: item.display_name, value: item._id }
              response autoData
    }

  setup: ->
    @filterPatientsDialog = @$("#filterPatientsDialog")
    @setupTag "#payerTags", "api/value_sets/2.16.840.1.114222.4.11.3591.json?search="
    @setupTag "#raceTags", "api/value_sets/2.16.840.1.114222.4.11.836.json?search="
    @setupTag "#ethnicityTags", "api/value_sets/2.16.840.1.114222.4.11.837.json?search="
    @setupTag "#problemListTags", "api/value_sets/measure"
    @setupTag "#ageTags", null, "e.g. 18-25, >=30"

  display: ->
    @filterPatientsDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    @filterPatientsDialog.modal('hide')
