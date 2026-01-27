///|
priv suberror EmptyPatternError {
  EmptyPatternError(String)
} derive(Show)

///|
priv suberror PatternTooLongError {
  PatternTooLongError(String)
} derive(Show)

///|
priv suberror OptionChooseError {
  OptionChooseError(String)
} derive(Show)

///|
priv suberror InvalidRangeError {
  InvalidRangeError(String)
} derive(Show)
