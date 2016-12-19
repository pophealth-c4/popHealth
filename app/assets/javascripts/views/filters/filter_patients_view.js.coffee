class Thorax.Views.FilterPatients extends Thorax.Views.BaseFilterView
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

  setup: ->
    @filterPatientsDialog = @$("#filterPatientsDialog")
    @setupSelect2 "#payerTags", "api/value_sets/2.16.840.1.114222.4.11.3591.json?search="
    @setupSelect2 "#raceTags", "api/value_sets/2.16.840.1.114222.4.11.836.json?search="
    @setupSelect2 "#ethnicityTags", "api/value_sets/2.16.840.1.114222.4.11.837.json?search="
    @setupSelect2 "#problemListTags", "api/value_sets/measure"
    @setupTagIt "#ageTags", "e.g. 18-25, >=30"

  display: ->
    @filterPatientsDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    filter = []
    filter.push @getSelect2Values "#payerTags", "payer"
    filter.push @getSelect2Values "#raceTags", "race"
    filter.push @getSelect2Values "#ethnicityTags", "ethnicity"
    filter.push @getSelect2Values "#problemListTags", "problemList"
    @filterPatientsDialog.modal('hide')
    @trigger('filterSaved', filter)
