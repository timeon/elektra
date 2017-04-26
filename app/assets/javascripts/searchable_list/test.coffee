#= require searchable_list/index

{ div, a, table, tbody, tr, td, p,button, span, i, form, input } = React.DOM

Header = () ->
  div null,
    a href: '#', className: 'btn btn-primary', 'Test'

TestList = ({items}) ->
  div null,
    if items
      table className: 'table instances',
        tbody null,
          for item in items
            tr key: item.id,
              td null, item.name
    else
      p null, 'No items found!'


window.TestList = SearchableList.Wrapper(header: Header, body: TestList)
