enum CommandType {
  //send by kids & parents;
  volume,
  //send by kid:
  deviceInfo,
  playingInfo, //info now playing
  playList, //playlist
  playingError,
  thumbnail,
  play,
  pause,
  stop,
  next,
  previous,
  lock,
  rotate
}

extension ParseCToString on CommandType {
  String value() {
    return toString().split('.').last;
  }
}