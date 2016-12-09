class Thorax.Views.FilterProviders extends Thorax.Views.BaseFilterView
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

  setup: ->
    @filterProvidersDialog = @$("#filterProvidersDialog")
    @setupSelect2 "#npiTags", "api/providers/search?npi="
    @setupSelect2 "#tinTags", "api/practices/search?tin="
    @setupSelect2 "#providerTypeTags", "api/value_sets/2.16.840.1.113762.1.4.1026.23.json?search="
    @setupSelect2 "#addressTags", "api/practices/search?address="

  display: ->
    @filterProvidersDialog.modal(
      "backdrop" : "static",
      "keyboard" : true,
      "show" : true)

  submit: ->
    filter = []
    filter.push @getSelect2Values "#npiTags", "npi"
    filter.push @getSelect2Values "#tinTags", "tin"
    filter.push @getSelect2Values "#providerTypeTags", "providerType"
    filter.push @getSelect2Values "#addressTags", "address"
    @filterProvidersDialog.modal('hide')
    @trigger('filterSaved', filter)
