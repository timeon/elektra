{ connect } = ReactRedux
{ div, button, span, form, input, i } = React.DOM
{ handleSubmit, loadNextItems, updateSearchTerm } = SearchableList

Header = (WrappedComponent, options = {}) ->
  Content = (props) ->
    {items, fields, isFetching, lastReceivedAt,setSearchTerm} = props

    div className: 'toolbar',
      # if errors
      #   div className: 'alert alert-error', React.createElement ReactFormHelpers.Errors, errors: errors


      div className: "col-lg-6",
        div className: "input-group",
          input
            type: "text",
            className: "form-control string search-term",
            placeholder: "Search for...",
            onChange: ((e) -> e.preventDefault(); setSearchTerm(e.target.value.trim());)
          span className: "input-group-addon",
            i className: 'fa fa-search'
          # span className: "input-group-btn",
          #   button className: "btn btn-primary", type: "submit", onClick: ((e) -> e.preventDefault(); handleSubmit()), "Go!"

      React.createElement WrappedComponent, props if WrappedComponent

  Content= connect(
    (state, ownProps) ->
      listName = ownProps.listName
      listState = state.searchableLists[listName]
      lastReceivedAt: if listState then listState.lastReceivedAt else null
      isFetching: if listState then listState.isFetching else false
    (dispatch,ownProps) ->
      listName = ownProps.listName
      handleSubmit: -> dispatch(fetchNextItems(listName))
      setSearchTerm: (searchTerm) -> dispatch(updateSearchTerm(listName,searchTerm))
      loadNextItems: -> dispatch(fetchNextItems(listName))
  )(Content)

SearchableList.Header = Header
