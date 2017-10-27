import PropTypes from 'prop-types';
import { Modal, Button } from 'react-bootstrap';
import { Form } from 'elektra-form';
import { Link } from 'react-router-dom';

const protocols = ['NFS','CIFS']

export default class NewShareFormWrapper extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {show: true};
    this.close = this.close.bind(this)
    this.onSubmit = this.onSubmit.bind(this)
  }

  validate(values) {
    return values.share_proto && values.size && values.share_network_id && true
  }

  close(e){
    if(e) e.stopPropagation()
    this.setState({show: false})
    setTimeout(() => this.props.history.replace('/shares'),300)
  }

  onSubmit(values, {handleSuccess,handleErrors}){
    this.props.handleSubmit(values,{
      handleSuccess: () => {
        handleSuccess()
        this.close()
      },
      handleErrors: handleErrors
    })
  }

  render(){
    return (
      <Modal show={this.state.show} onHide={this.close} bsSize="large" aria-labelledby="contained-modal-title-lg">
        <Modal.Header closeButton>
          <Modal.Title id="contained-modal-title-lg">New Share</Modal.Title>
        </Modal.Header>

        <Form
          className='form form-horizontal'
          validate={this.validate}
          onSubmit={this.onSubmit}>

          <Modal.Body>
            <Form.Errors/>

            <Form.ElementHorizontal label='Name' name="name">
              <Form.Input elementType='input' type='text' name='name'/>
            </Form.ElementHorizontal>

            <Form.ElementHorizontal label='Description' name="description">
              <Form.Input elementType='textarea' className="text optional form-control" name="description"/>
            </Form.ElementHorizontal>

            <Form.ElementHorizontal label='Protocol' required={true} name="share_proto">
              <Form.Input elementType='select' className="select required form-control" name='share_proto'>
                <option></option>
                {protocols.map((protocol,index) =>
                  <option value={protocol} key={index}>{protocol}</option>
                )}
              </Form.Input>
            </Form.ElementHorizontal>

            <Form.ElementHorizontal label='Size (GiB)' name="size" required={true}>
              <Form.Input elementType='input' className="integer required optional form-control" type="number"
                name="size"/>
            </Form.ElementHorizontal>

            <Form.ElementHorizontal label='Availability Zone' name="share_az">
              { this.props.availabilityZones.isFetching ? (
                <span><span className='spinner'></span>Loading...</span>
              ) : (
                <div>
                  <Form.Input elementType='select' name='availability_zone' className="required select form-control">
                    <option></option>
                    { this.props.availabilityZones.items.map((az,index) =>
                      <option value={az.id} key={index}>{az.name}</option>
                    )}
                  </Form.Input>

                  { this.props.availabilityZones.items.length==0 &&
                    <p className='help-block'>
                      <i className="fa fa-info-circle"></i>
                      No availability zones available.
                    </p>
                  }
                </div>
              )}
            </Form.ElementHorizontal>


            <Form.ElementHorizontal label='Share Network' name="share_network" required={true}>
              { this.props.shareNetworks.isFetching ? (
                <span><span className='spinner'></span>Loading...</span>
              ) : (
                <div>
                  <Form.Input elementType='select' name="share_network_id"
                    className="required select form-control">
                    <option></option>
                    {this.props.shareNetworks.items.map((sn,index) =>
                      <option value={sn.id} key={sn.id}>{sn.name}</option>
                    )}
                  </Form.Input>
                  { this.props.shareNetworks.items.length==0 &&
                    <p className='help-block'>
                      <i className="fa fa-info-circle"></i>
                      There are no share networks defined yet.
                      <Link to="/share-networks/new">Create a new share network.</Link>
                    </p>
                  }
                </div>
              )}
            </Form.ElementHorizontal>
          </Modal.Body>
          <Modal.Footer>
            <Button onClick={this.close}>Cancel</Button>
            <Form.SubmitButton label='Save'/>
          </Modal.Footer>
        </Form>
      </Modal>
    );
  }
}
