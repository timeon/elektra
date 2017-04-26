{ connect } = ReactRedux
{ div, button, span, form, input } = React.DOM

# body wrapper
Body = (WrappedComponent, options = {}) ->
  Content = ({listName, items, searchFields, lastReceivedAt, searchTerm}) ->
    values= (item) ->
      result = []
      (result.push(item[key]) if item[key]) for key in searchFields
      result

    searchFilter= (item) ->
      return true if !searchTerm or searchTerm.length==0
      success = false
      success = (success or value.toString().match(eval('/'+searchTerm+'/gi'))!=null) for value in values(item)
      success

    relevantItems = () ->
      return null unless items
      items.filter(searchFilter)

    div null,
      React.createElement WrappedComponent, listName: listName, items: relevantItems()

  # connect body to store
  Content = connect(
    (state, ownProps) ->
      listName = ownProps.listName
      listState = state.searchableLists[listName] || {}

      searchTerm:     listState.searchTerm
      items:          listState.items
      lastReceivedAt: listState.lastReceivedAt
    (dispatch,ownProps) ->
  )(Content)

# export
SearchableList.Body = Body
