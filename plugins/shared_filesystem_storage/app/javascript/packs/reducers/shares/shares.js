import * as constants from '../../constants';

//########################## SHARES ##############################
const initialSharesState = {
  items: [],
  receivedAt: null,
  updatedAt: null,
  isFetching: false
};

const requestShares=(state,{requestedAt})=>
  Object.assign({},state,{isFetching: true, requestedAt});

const requestSharesFailure=function(state,...rest){
  const obj = rest[0];
  return Object.assign({},state,{isFetching: false});
};

const receiveShares=(state,{shares,receivedAt})=>
  Object.assign({},state,{
    isFetching: false,
    items: shares,
    receivedAt
  })
;

const requestShare= function(state,{shareId,requestedAt}) {
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }

  const newState = ReactHelpers.cloneHashMap(state);
  newState.items[index].isFetching = true;
  newState.items[index].requestedAt = requestedAt;
  return newState;
};

const requestShareFailure=function(state,{shareId}){
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }

  const newState = ReactHelpers.cloneHashMap(state);
  newState.items[index].isFetching = false;
  return newState;
};

const receiveShare= function(state,{share}) {
  const index = ReactHelpers.findIndexInArray(state.items,share.id);
  const items = state.items.slice();
  // update or add
  if (index>=0) { items[index]=share; } else { items.push(share); }
  return Object.assign({},state,{items});
};

const requestDeleteShare= function(state,{shareId}) {
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }

  const newState = ReactHelpers.cloneHashMap(state);
  newState.items[index].isDeleting = true;
  return newState;
};

const deleteShareFailure= function(state,{shareId}) {
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }

  const newState = ReactHelpers.cloneHashMap(state);
  newState.items[index].isDeleting = false;
  return newState;
};

const deleteShareSuccess= function(state,{shareId}) {
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }
  const items = state.items.slice();
  items.splice(index,1);
  return Object.assign({},state,{items});
};

const receiveShareExportLocations= function(state,{shareId,export_locations}){
  console.log(shareId,export_locations)
  const index = state.items.findIndex((item) => item.id==shareId);
  if (index<0) { return state; }
  const items = state.items.slice();
  items[index].export_locations = export_locations;
  return Object.assign({},state,{items});
};

// shares reducer
export const shares = function(state, action) {
  if (state == null) { state = initialSharesState; }
  switch (action.type) {
    case constants.RECEIVE_SHARES: return receiveShares(state,action);
    case constants.REQUEST_SHARES: return requestShares(state,action);
    case constants.REQUEST_SHARES_FAILURE: return requestSharesFailure(state,action);
    case constants.REQUEST_SHARE: return requestShare(state,action);
    case constants.REQUEST_SHARE_FAILURE: return requestShareFailure(state,action);
    case constants.RECEIVE_SHARE: return receiveShare(state,action);
    case constants.REQUEST_DELETE_SHARE: return requestDeleteShare(state,action);
    case constants.DELETE_SHARE_FAILURE: return deleteShareFailure(state,action);
    case constants.DELETE_SHARE_SUCCESS: return deleteShareSuccess(state,action);
    case constants.REQUEST_SHARE_EXPORT_LOCATIONS: return state;
    case constants.RECEIVE_SHARE_EXPORT_LOCATIONS: return receiveShareExportLocations(state,action);

    default: return state;
  }
};
