export const AccessControlItem = ({handleDelete, rule}) => {
  const humanizeAccessLevel = () => {
    switch (rule.access_level) {
      case 'ro':
        return 'read only'
      case 'rw':
        return 'read/write'
      default:
        return rule.access_level
  }}

  return (
    <tr className={ rule.isDeleting && 'updating' }>
      <td>{rule.access_type}</td>
      <td>{rule.access_to}</td>
      <td className={ rule.access_level == 'rw' ? 'text-success' : 'text-info'}>
        <i className={`fa fa-fw fa-${rule.access_level == 'rw' ? 'pencil-square' : 'eye'}`}/>
        { humanizeAccessLevel() }
      </td>
      <td>{rule.state}</td>
      <td className='snug'>
        <button className='btn btn-danger btn-sm' onClick={(e) => { e.preventDefault(); handleDelete(rule.id)}}>
          <i className='fa fa-minus'/>
        </button>
      </td>
    </tr>
  )
}
