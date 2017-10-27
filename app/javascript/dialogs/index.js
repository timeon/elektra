import { Dialog } from './dialog';

const showDialog = function(type, message, options) {
  let cleanup;
  let component;
  let props;
  let wrapper;

  if (options == null) {
    options = {size: 'large'};
  }
  switch(type) {
    case 'confirm':
      options['confirmLabel'] = options['confirmLabel'] || 'Yes';
      options['abortLabel'] = options['abortLabel'] || 'No';
      options['showAbortButton'] = true;
      break;
    case 'info':
      options['confirmLabel'] = options['confirmLabel'] || 'OK';
      options['showAbortButton'] = (options['showAbortButton'] === true)
      break;
    case 'error':
      options['confirmLabel'] = options['confirmLabel'] || 'OK';
      options['showAbortButton'] = (options['showAbortButton'] === true)
      break;
  }

  wrapper = document.body.appendChild(document.createElement('div'));
  cleanup = function() {
    ReactDOM.unmountComponentAtNode(wrapper)
    return setTimeout(function() {
      return wrapper.remove();
    });
  };

  props = Object.assign({ message, type, onHide: cleanup}, options);
  component = ReactDOM.render(React.createElement(Dialog,props), wrapper);
  return component.promise
};

export const confirm = function(message, options) {
  return showDialog('confirm', message, options);
};

export const showInfoModal = function(message, options) {
  return showDialog('info', message, options);
};

export const showErrorModal = function(message, options) {
  return showDialog('error', message, options);
};
