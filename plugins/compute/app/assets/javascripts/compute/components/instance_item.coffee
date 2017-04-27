{ div, a, tr, td, i, p, span } = React.DOM

NO_STATE    = 0
RUNNING     = 1
BLOCKED     = 2
PAUSED      = 3
SHUT_DOWN   = 4
SHUT_OFF    = 5
CRASHED     = 6
SUSPENDED   = 7
FAILED      = 8
BUILDING    = 9

power_state_string=(item) ->
  switch item['OS-EXT-STS:power_state']
    when RUNNING then "Running"
    when BLOCKED then "Blocked"
    when PAUSED then "Paused"
    when SHUT_DOWN then "Shut down"
    when SHUT_OFF then "Shut off"
    when CRASHED then "Crashed"
    when SUSPENDED then "Suspended"
    when FAILED then "Failed"
    when BUILDING then "Building"
    else 'No State'


InstanceItem = ({item, root_url, all_projects}) ->

  data = {}
  console.log item
  if item.task_state
    data['update_url']="#{root_url}/#{item.id}/update_item"
    data['interval']=2500

  tr className: "state-#{(item.status.toLowerCase() if item.status)} #{('task-state ' + item.task_state if item.task_state)}", data: data, id: "instance_#{item.id}",
    td null,
      if item.permissions and item.permissions.can_read
        a href: "#{root_url}/#{item.id}", 'data-modal': true, item.name
      else
        item.name
    if all_projects
      td null, 'Project Name'

    td null, item['OS-EXT-AZ:availability_zone']
    td className: 'snug-nowrap',
      for network_name, ip_values of item.addresses
        if ip_values and ip_values.length>0
          div className: 'list-group borderless', key: network_name,
            network_name
            for values in ip_values
              p className: 'list-group-item-text', key: values['addr'],
                if values["OS-EXT-IPS:type"]=='floating'
                  i className: 'fa fa-globe fa-fw'
                else if values["OS-EXT-IPS:type"]=='fixed'
                  i className: 'fa fa-desktop fa-fw'
                " #{values["addr"]} "
                span className: 'info-text', values["OS-EXT-IPS:type"]

    td null, 'image'#item.image
    td null, 'flavor'#item.flavor
    td null, power_state_string(item)
    td null,
      if item.task_state then item.task_state else item.status
      if item.fault
        br null
        span className: 'info-text', item.fault["message"]
    td null, item.pretty_created_at

compute.InstanceItem = InstanceItem


  #
  # %td.snug
  #   - if current_user.is_allowed?("compute:instance_delete", {target: { project: @active_project, scoped_domain_name: @scoped_domain_name}}) or current_user.is_allowed?("compute:instance_update", {})
  #     .btn-group
  #       %button.btn.btn-default.btn-sm.dropdown-toggle{ type: "button", data: { toggle: "dropdown"}, aria: { expanded: true} }
  #         %span.fa.fa-cog
  #         -# %span.spinner
  #
  #       %ul.dropdown-menu.dropdown-menu-right{ role:"menu"}
  #         - if current_user.is_allowed?("compute:instance_get", {target: { project: @active_project, scoped_domain_name: @scoped_domain_name}})
  #           %li= link_to 'VNC Console', console_instance_path(id: instance.id), target: '_blank'#data: { modal: true, load_console: true}
  #
  #         -# Add other actions only if instance is not in a transitioning state (creating, starting, ...)
  #         - unless instance.os_ext_sts_task_state
  #
  #           - if current_user.is_allowed?("compute:instance_update", {target: { project: @active_project, scoped_domain_name: @scoped_domain_name}})
  #             - if instance.floating_ips.length>0
  #               %li= link_to 'Detach Floating IP', plugin('compute').detach_floatingip_instance_path(id: instance.id, floating_ip: instance.floating_ips.first["addr"]), method: :delete, data: { confirm: 'Are you sure you want to detach floating?', ok: "Yes, detach it", confirmed: :loading_status}, remote: true
  #             - else
  #               %li= link_to 'Attach Floating IP', new_floatingip_instance_path(id: instance.id), data: {modal: true }
  #
  #
  #             %li= link_to 'Attach Interface', plugin('compute').attach_interface_instance_path(id: instance.id), data: { modal: true}
  #             %li= link_to 'Detach Interface', plugin('compute').detach_interface_instance_path(id: instance.id), data: { modal: true}
  #
  #             - if [Compute::Server::SUSPENDED,Compute::Server::PAUSED,Compute::Server::SHUT_DOWN,Compute::Server::SHUT_OFF].include? instance.power_state
  #               %li= link_to 'Start', start_instance_path(id: instance.id), method: :put, data: {loading_status: true}, remote: true
  #
  #             - if instance.status=='ACTIVE' or instance.status=='SHUTOFF'
  #               %li= link_to 'Resize', new_size_instance_path(id: instance.id), data: { modal: true}
  #
  #             - if ['ACTIVE', 'SHUTOFF', 'PAUSED', 'SUSPENDED.'].include?(instance.status)
  #               %li= link_to 'Create Snapshot', new_snapshot_instance_path(id: instance.id), data: { modal: true}
  #
  #             - if instance.status=='VERIFY_RESIZE'
  #               %li= link_to 'Confirm Resize', plugin('compute').confirm_resize_instance_path(id: instance.id), method: :put, data: {loading_status: true}, remote: true
  #               %li= link_to 'Revert Resize', plugin('compute').revert_resize_instance_path(id: instance.id), method: :put, data: {loading_status: true}, remote: true
  #
  #
  #             - if instance.power_state==Compute::Server::RUNNING
  #               %li.divider
  #               %li= link_to 'Stop', plugin('compute').stop_instance_path(id: instance.id), method: :put, data: { confirm: 'Are you sure you want to stop this instance?', ok: "Yes, stop it", confirmed: :loading_status}, remote: true
  #
  #               %li= link_to 'Reboot', plugin('compute').reboot_instance_path(id: instance.id), method: :put, data: { confirm: 'Are you sure you want to reboot this instance?', ok: "Yes, reboot it", confirmed: :loading_status}, remote: true
  #
  #               %li= link_to 'Pause', plugin('compute').pause_instance_path(id: instance.id), method: :put, data: { confirm: 'Are you sure you want to pause this instance?', ok: "Yes, stop it", confirmed: :loading_status }, remote: true
  #
  #               %li= link_to 'Suspend', plugin('compute').suspend_instance_path(id: instance.id), method: :put, data: { confirm: 'Are you sure you want to suspend this instance?', ok: "Yes, stop it", confirmed: :loading_status}, remote: true
  #
  #           - if current_user.is_allowed?("compute:instance_delete", {target: { project: @active_project, scoped_domain_name: @scoped_domain_name}})
  #             %li= link_to 'Terminate', plugin('compute').instance_path(id: instance.id), method: :delete, data: { confirm: 'Are you sure you want to terminate this instance?', ok: "Yes, terminate it", confirmed: :loading_status}, remote: true
