import ExpoBluetooth from './ExpoBluetooth';

export const {
  BLUETOOTH_EVENT,
  UUID,
  TYPES,
  /* iOS */
  CENTRAL_OPTIONS,
  SCAN_OPTIONS,
  CONNECT_PERIPHERAL_OPTIONS,
  /* Android */
  PRIORITY,
} = ExpoBluetooth;

export const DELIMINATOR = '|';

export const EVENTS: {
  SYSTEM_ENABLED_STATE_CHANGED?: 'SYSTEM_ENABLED_STATE_CHANGED';
  CENTRAL_STATE_CHANGED: 'CENTRAL_STATE_CHANGED';
  CENTRAL_DISCOVERED_PERIPHERAL: 'CENTRAL_DISCOVERED_PERIPHERAL';
  PERIPHERAL_DISCOVERED_SERVICES: 'PERIPHERAL_DISCOVERED_SERVICES';
  PERIPHERAL_CONNECTED: 'PERIPHERAL_CONNECTED';
  PERIPHERAL_DISCONNECTED: 'PERIPHERAL_DISCONNECTED';
  PERIPHERAL_BONDED?: 'PERIPHERAL_BONDED';
  PERIPHERAL_UNBONDED?: 'PERIPHERAL_UNBONDED';
  PERIPHERAL_UPDATED_RSSI: 'PERIPHERAL_UPDATED_RSSI';
  PERIPHERAL_UPDATED_MTU?: 'PERIPHERAL_UPDATED_MTU';
  SERVICE_DISCOVERED_INCLUDED_SERVICES: 'SERVICE_DISCOVERED_INCLUDED_SERVICES';
  SERVICE_DISCOVERED_CHARACTERISTICS: 'SERVICE_DISCOVERED_CHARACTERISTICS';
  CHARACTERISTIC_DISCOVERED_DESCRIPTORS: 'CHARACTERISTIC_DISCOVERED_DESCRIPTORS';
  CHARACTERISTIC_DID_WRITE: 'CHARACTERISTIC_DID_WRITE';
  CHARACTERISTIC_DID_READ: 'CHARACTERISTIC_DID_READ';
  CHARACTERISTIC_DID_NOTIFY: 'CHARACTERISTIC_DID_NOTIFY';
  DESCRIPTOR_DID_WRITE: 'DESCRIPTOR_DID_WRITE';
  DESCRIPTOR_DID_READ: 'DESCRIPTOR_DID_READ';
} = ExpoBluetooth.EVENTS;
