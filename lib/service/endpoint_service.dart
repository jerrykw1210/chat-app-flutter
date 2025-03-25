
enum ServiceTypeEnum {
  webSocket('WEB_SOCKET'),
  turmsUserMobile('TURMS_USER_MOBILE'),
  account('ACCOUNT'),
  auth('AUTH'),
  admin('ADMIN'),
  customerService('CUSTOMER_SERVICE'),
  file('FILE'),
  turmsUserWeb('TURMS_USER_WEB'),
  feedback('FEEDBACK'),
  user('USER'),
  turmsAdmin('TURMS_ADMIN');

  const ServiceTypeEnum(this.key);
  final String key;
}

class EndpointService {
  final Map<String, dynamic> _serviceURLMap;

  EndpointService(this._serviceURLMap);

  String _getValue(ServiceTypeEnum serviceType) =>
      _serviceURLMap[serviceType.key]?['url'] ?? '';

  // String _getValue(ServiceTypeEnum serviceType) {
  //   return _serviceURLMap[serviceType.key]?['url'] ?? '';
  // }

  String getEndpoint(ServiceTypeEnum serviceType) => _getValue(serviceType);
}
