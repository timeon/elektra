#= require searchable_list/index
#= require compute/components/instance_item

{ div, a, table, thead, tbody, tr, th, td, p,button, span, i, form, input } = React.DOM

Header = ({permissions,root_url}) ->
  div null,
    if permissions['can_create']
      a href: "#{root_url}/new", "data-modal": true, className: 'btn btn-primary btn-lg', 'Create new'

InstanceList = ({items,permissions,all_projects,root_url}) ->
  div null,
    table className: 'table instances',
      thead null,
        tr null,
          th null, 'Name'
          if all_projects
            th null, 'Owning Project'
          th null,
            'AZ'
            i className: 'fa fa-fw fa-info-circle', 'data-toggle': 'tooltip', 'data-placement': 'top', 'data-title': 'Availability Zone'
          th null, 'IPs'
          th null, 'OS'
          th null, 'Size'
          th null, 'Power state'
          th null, 'Status'
          th null, 'Created at'
          th className: 'snug'
      tbody null,
        if items.length==0
          tr 'data-empty': true,
           td colspan: (if all_projects then 10 else 9), 'No instances available'
        else
          for item in items
            React.createElement compute.InstanceItem, key: item.id, item: item, root_url: root_url, all_projects: all_projects


compute.Instances = SearchableList.Wrapper(header: Header, body: InstanceList)
