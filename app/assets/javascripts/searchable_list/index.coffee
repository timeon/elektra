#= require searchable_list/setup
#= require searchable_list/constants
#= require searchable_list/actions/index
#= require searchable_list/reducers/index
#= require searchable_list/components/header
#= require searchable_list/components/body
#= require searchable_list/components/footer
#= require react/helpers

{ div } = React.DOM
{ createStore, applyMiddleware, compose, combineReducers } = Redux
{ Provider, connect } = ReactRedux
{ AppReducers, Header, Body, Footer, setInitialItems, setUrl, setHasNext } = SearchableList

composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose
store = createStore(AppReducers, composeEnhancers(applyMiddleware(ReduxThunk.default)))

defaultName = 'list'
defaultCount = 0

SearchableList.ajaxHelper = new ReactAjaxHelper()

# this class wrapes a lis component of items
SearchableList.Wrapper = (options = {}) ->

  # return a container including all needed components
  AppProvider = React.createClass
    getDefaultProps: ->
      # set default list name
      name: "#{defaultName}#{defaultCount++}"
      searchFields: ["id","name","description"]

    componentWillMount: ->
      # load items into state bevore rendering
      store.dispatch(setInitialItems(@props.name,@props.items)) if @props.items
      store.dispatch(setUrl(@props.name,@props.search_url)) if @props.search_url
      store.dispatch(setHasNext(@props.name,@props.has_next)) if @props.has_next

    render: ->
      newProps = ReactHelpers.mergeObjects({},@props,{ listName: @props.name})
      React.createElement Provider, store: store,
        div null,
          # render header
          React.createElement Header(options['header']), newProps
          # render body with wrapped component
          React.createElement Body(options['body']), newProps
          # render footer which contains the load next button
          React.createElement Footer, listName: @props.name

window.SearchableList = SearchableList
