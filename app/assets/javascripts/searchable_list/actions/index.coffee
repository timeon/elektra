#= require react/ajax_helper
#= require_tree .

((app) ->
  #################### SEARCH RESULT ITEMS #########################
  setUrl=(listName,url) ->
    listName: listName
    url: url
    type: app.SET_URL

  setHasNext=(listName,hasNext) ->
    listName: listName
    hasNext: hasNext
    type: app.SET_HAS_NEXT

  setInitialItems=(listName,items) ->
    listName: listName
    type: app.SET_INITIAL_ITEMS
    items: items
    receivedAt: Date.now()

  updateSearchTerm=(listName,searchTerm) ->
    listName: listName
    type: app.UPDATE_SEARCH_TERM
    searchTerm: searchTerm

  requestNextItems= (listName) ->
    listName: listName
    type: app.REQUEST_NEXT_ITEMS
    requestedAt: Date.now()

  requestNextItemsFailure= (listName,errors) ->
    listName: listName
    type: app.REQUEST_NEXT_ITEMS_FAILURE
    errors: errors

  receiveNextItems= (listName,json) ->
    listName: listName
    type: app.RECEIVE_NEXT_ITEMS
    receivedAt: Date.now()
    items: json

  fetchNextItems = (listName,auto=false) ->
    (dispatch, getState) ->
      dispatch(requestNextItems(listName))
      listState = getState().searchableLists[listName] || {}

      items = listState.items
      url = listState.url || ''
      marker = items[items.length-1]
      page = listState.page+1
      data = {per_page: 100, search_mode: true, page: page}
      data['marker'] = marker.id if marker

      app.ajaxHelper.get url,
        data: data
        dataType: 'json'
        success: (data, textStatus, jqXHR) ->
          hasNext = data.length>0
          dispatch(setHasNext(listName,hasNext))
          dispatch(receiveNextItems(listName,data))
          if auto==true and hasNext
            dispatch(fetchNextItems(listName,auto))
        error: ( jqXHR, textStatus, errorThrown) ->
          dispatch(requestNextItemsFailure(listName,errorThrown))


  app.setUrl                      = setUrl
  app.setHasNext                  = setHasNext
  app.setInitialItems             = setInitialItems
  app.fetchNextItems              = fetchNextItems
  app.updateSearchTerm            = updateSearchTerm

)(SearchableList)
