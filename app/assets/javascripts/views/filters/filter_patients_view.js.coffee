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
   
  setupSelect: (elementSelector, url, placeholder) ->
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

  setupTag: (elementSelector, placeholder) ->
    $(elementSelector).tagit {
      allowSpaces: true
      placeholderText: placeholder
      animate: false
      removeConfirmation: true
    }

  setup: ->
    @filterPatientsDialog = @$("#filterPatientsDialog")
    @setupSelect "#payerTags", "api/value_sets/2.16.840.1.114222.4.11.3591.json?search="
    @setupSelect "#raceTags", "api/value_sets/2.16.840.1.114222.4.11.836.json?search="
    @setupSelect "#ethnicityTags", "api/value_sets/2.16.840.1.114222.4.11.837.json?search="
    @setupSelect "#problemListTags", "api/value_sets/measure"
    @setupTag "#ageTags", "e.g. 18-25, >=30"

  display: ->
    @filterPatientsDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  getSelect2Values: (elementSelector, fieldName) ->
    data = { filter : fieldName, items : [] }
    $(elementSelector + " option:selected").each (item) ->
      data.items.push({id: item.value, text: item.text })

  submit: ->
    @getSelect2Values "#payerTags", "payer"
    @filterPatientsDialog.modal('hide')
    @trigger('filterSaved')
