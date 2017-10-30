import { connect } from  'react-redux';
import EditSecurityServiceModal from '../../components/security_services/edit';
import { submitEditSecurityServiceForm } from '../../actions/security_services';

export default connect(
  ({shared_filesystem_storage:state}, ownProps ) => {
    let securityService, isFetching;
    let match = ownProps.match
    if (match && match.params && match.params.id) {
      isFetching = state.securityServices.isFetching;
      let securityServices = state.securityServices.items
      if (securityServices) securityService = securityServices.find(item => item.id==match.params.id)
    }

    return { isFetching, securityService }
  },
  dispatch => ({
    handleSubmit: (values,{handleSuccess,handleErrors}) =>
      dispatch(submitEditSecurityServiceForm(values,{handleSuccess,handleErrors}))
  })
)(EditSecurityServiceModal);
