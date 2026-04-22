///|
priv suberror EmptyPatternError {
  EmptyPatternError(String)
} derive(Debug)

///|
priv suberror PatternTooLongError {
  PatternTooLongError(String)
} derive(Debug)

///|
priv suberror OptionChooseError {
  OptionChooseError(String)
} derive(Debug)

///|
priv suberror InvalidRangeError {
  InvalidRangeError(String)
} derive(Debug)
