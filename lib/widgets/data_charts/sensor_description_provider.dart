

class SensorDescriptionProvider {
  static final Map<String, String> _sensorDescriptions = {
    'cport2': 
        'Sonification counts are the counts of high and low voltages being received back from the Pulsar head. Complementing the sonification voltage; this is a useful diagnostic measurement to determine the heads integrity.',
    'vport2': 
        'Sonification voltage is the measure of voltage being received back from the Pulsar head. Complementing the sonification counts; this is a useful diagnostic measurement to determine the heads integrity.',
    'vport1':
        'The power supply output voltage is a measure of raw voltage electricity from the power supply currently powering the Pulsar head. This is a diagnostic measurement to determine that a Pulsar head is receiving the correct amount of power to be functional.',
    'cport3':
        'Sonification counts are the counts of high and low voltages being received back from the Pulsar head. Complementing the sonification voltage; this is a useful diagnostic measurement to determine the heads integrity.',
    'vport3':
        'Sonification voltage is the measure of voltage being received back from the Pulsar head. Complementing the sonification counts; this is a useful diagnostic measurement to determine the heads integrity.',
  };

  // Method to get the description of a sensor by its internal sensor name (e.g. 'cport2', 'bg', etc.)
  static String getDescription(String sensorName) {
    return _sensorDescriptions[sensorName] ??
        'Description coming soon!';
  }
}
