{ connect } = ReactRedux
{ div, button, span, a, i } = React.DOM
{ fetchNextItems } = SearchableList

Footer = ({isFetching, hasNext, lastReceivedAt, loadNextItems, loadAllItems}) ->
  div className: 'pull-right',
    if isFetching
      span className: 'spinner'
    else if hasNext
      div null,
        a className: 'btn btn-primary', onClick: ((e) -> e.preventDefault(); loadNextItems()), 'Load Next Items'
        a className: 'btn btn-primary', onClick: ((e) -> e.preventDefault(); loadAllItems()), 'Load All Items'

Footer= connect(
  (state, ownProps) ->
    listName = ownProps.listName
    listState = state.searchableLists[listName] || {}
    lastReceivedAt: listState.lastReceivedAt
    isFetching: listState.isFetching
    hasNext: listState.hasNext
  (dispatch,ownProps) ->
    listName = ownProps.listName
    loadNextItems: -> dispatch(fetchNextItems(listName))
    loadAllItems: -> dispatch(fetchNextItems(listName,true))
)(Footer)

SearchableList.Footer = Footer
