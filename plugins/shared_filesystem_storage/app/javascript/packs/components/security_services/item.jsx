import { Link } from 'react-router-dom';
import 'policy';

export default ({ securityService, handleDelete }) =>
  <tr className={ securityService.isDeleting ? 'updating' : ''}>
    <td>
      <Link to={`/security-services/${securityService.id}/show`}>{securityService.name}</Link>
      <br/>
      <span className='info-text'>{securityService.id}</span>
    </td>
    <td>{securityService.type}</td>
    <td>{securityService.status}</td>
    <td className="snug">
      { (policy.isAllowed("shared_filesystem_storage:security_service_delete") ||
         policy.isAllowed("shared_filesystem_storage:security_service_update")) &&
        <div className='btn-group'>
          <button className='btn btn-default btn-sm dropdown-toggle' type='button' data-toggle='dropdown' aria-expanded={true}>
            <span className='fa fa-cog'></span>
          </button>

          <ul className='dropdown-menu dropdown-menu-right' role="menu">
            { policy.isAllowed("shared_filesystem_storage:security_service_delete") &&
              <li>
                <a href='javascript:void(0)' onClick={(e) => {e.preventDefault(); handleDelete(securityService.id)}}>Delete</a>
              </li>
            }
            { policy.isAllowed("shared_filesystem_storage:security_service_update") &&
              <li><Link to={`/security-services/${securityService.id}/edit`}>Edit</Link></li>
            }
          </ul>
        </div>
      }
    </td>
  </tr>
