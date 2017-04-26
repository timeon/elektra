#= require react/helpers
#= require_tree .

{ combineReducers } = Redux

((app) ->
  ########################### LIST STATE ##############################
  initialState =
    url: null
    hasNext: null
    page: 1
    items: []
    searchTerm: null
    lastRequestedAt: null
    lastReceivedAt: null
    isFetching: false
    errors: null

  setHasNext=(state,{hasNext}) ->
    ReactHelpers.mergeObjects({},state,{
      hasNext: hasNext
    })

  setUrl=(state,{url})->
    ReactHelpers.mergeObjects({},state,{
      url: url
    })

  setInitialItems=(state,{items,receivedAt})->
    ReactHelpers.mergeObjects({},state,{
      items: items,
      lastReceivedAt: receivedAt
    })

  requestNextItems=(state,{requestedAt})->
    ReactHelpers.mergeObjects({},state,{
      isFetching: true,
      lastRequestedAt: requestedAt,
      errors: null
    })

  requestNextItemsFailure=(state,{errors})->
    ReactHelpers.mergeObjects({},state,{isFetching: false, errors: errors})

  receiveNextItems=(state,{items,receivedAt})->
    newState = ReactHelpers.mergeObjects({},state,{
      isFetching: false
      page: state.page+1,
      lastReceivedAt: receivedAt
    })
    newState.items = newState.items.concat(items)
    newState

  updateSearchTerm=(state, {searchTerm}) ->
    ReactHelpers.mergeObjects({},state,{searchTerm: searchTerm})

  # switch to the right action
  actionReducer = (state = initialState, action) ->
    switch action.type
      when app.SET_URL then setUrl(state,action)
      when app.SET_HAS_NEXT then setHasNext(state,action)
      when app.SET_SEARCH_FIELDS then setSearchFields(state,action)
      when app.SET_INITIAL_ITEMS then setInitialItems(state,action)
      when app.UPDATE_SEARCH_TERM then updateSearchTerm(state,action)
      when app.RECEIVE_NEXT_ITEMS then receiveNextItems(state,action)
      when app.REQUEST_NEXT_ITEMS then requestNextItems(state,action)
      when app.REQUEST_NEXT_ITEMS_FAILURE then requestNextItemsFailure(state,action)
      else state

  # select the list based on listName parameter in action
  listReducer = (state = {}, action) ->
    {listName} = action
    if listName
      ReactHelpers.mergeObjects({},state,{"#{listName}": actionReducer(state[listName], action)})
    else
      state

  # define app reducers. At this moment it is only one reducer but it allows to
  # add further reducers.
  app.AppReducers = combineReducers({
    "searchableLists":  listReducer
  })

)(SearchableList)
