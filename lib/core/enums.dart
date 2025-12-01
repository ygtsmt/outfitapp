enum RequestMethod {
  get,
  head,
  post,
  put,
  delete,
  connect,
  options,
  trace,
  patch,
}

enum EventStatus {
  idle,
  processing,
  success,
  failure,
}

enum VideoGenerateWithPollotStatus {
  waiting,
  succeed,
  failed,
  processing,
}

enum GenerateType {
  image,
  realtimeImage,
  video,
  videoTemplate,
}
