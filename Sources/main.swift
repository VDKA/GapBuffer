
extension UInt8 {
  var char: String {
    return String(UnicodeScalar(self))
  }
}

// abc|def
//let buffer = GapBuffer("abc🇪🇺def", cursorPosition: 1, gapSize: 5)
let buffer = GapBuffer("abcdef", cursorPosition: 1, gapSize: 1)

print(buffer)

buffer.move(.forward)
buffer.move(.backward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.forward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)
buffer.move(.backward)


//buffer.printCursorDepiction()
//print(#line)
//buffer.moveBackward()

