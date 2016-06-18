
extension Array {

  internal func pointersSurrounding(index: Index) -> (left: UnsafePointer<Element>, right: UnsafePointer<Element>) {

    guard indices.contains(index) else { fatalError("index out of bounds") }

    var baseAddress = withUnsafeBufferPointer { $0.baseAddress! }

    baseAddress += index

    return (baseAddress.advanced(by: -1), baseAddress.advanced(by: 1))
  }
}

class GapBuffer {

  var buffer: [UInt8]
  var gapSize: Int = 1

  var placeHolder = "_".utf8.first!

  var startAddress: UnsafeMutablePointer<UInt8> {
    return buffer.withUnsafeMutableBufferPointer { $0.baseAddress! }
  }

  /// Pointer to the byte directly before the Gap
  var left: UnsafeMutablePointer<UInt8>

  /// Pointer to the start of the gap
  var gapStart: UnsafeMutablePointer<UInt8> {
    return left.advanced(by: 1)
  }
  
  /*               __GAP__               */
  /* 0 S - - - L gS _ _ _ gE R - - - E 0 */
  
  /// Pointer to the end of the gap
  var gapEnd: UnsafeMutablePointer<UInt8> {
    return right.advanced(by: -1)
  }

  /// Pointer to the byte directly after the Gap
  var right: UnsafeMutablePointer<UInt8>
  
  var endAddress: UnsafeMutablePointer<UInt8> {
    return startAddress.advanced(by: buffer.endIndex)
  }

  init(_ contents: [UInt8], cursorPosition: Int, gapSize: Int) {

    precondition(contents.count > cursorPosition)
    
    buffer = contents

    buffer.insert(contentsOf: Array(repeating: placeHolder, count: numericCast(gapSize)), at: cursorPosition)

    let (l, r) = buffer.pointersSurrounding(index: cursorPosition)

    left = UnsafeMutablePointer(l)
    right = UnsafeMutablePointer(r + gapSize)

#if TESTING
    for p in gapStart ..< gapEnd {
      p.pointee = "_".utf8.first!
    }
#endif
  }

  convenience init(_ string: String, cursorPosition: Int, gapSize: Int) {
    let array = Array(string.utf8)
    self.init(array, cursorPosition: cursorPosition, gapSize: gapSize)
  }
}

extension GapBuffer {
  
  enum Direction { case forward, backward }

  func move(_ direction: Direction) {
    
#if TESTING
    defer {
      (gapStart.pointee, gapEnd.pointee) = (95, 95)
      print(debugDescription)
    }
#endif
    
    switch direction {
      
    case .forward where right == endAddress - gapSize:
      
#if TESTING
      print("at end of buffer!")
#endif

      return
      
    case .backward where left == startAddress:
      
#if TESTING
      print("at end of buffer!")
#endif

      return
      
    case .forward where UTF8.isContinuation(right.pointee):
      
      moveCodeUnit(.forward)
      move(.forward)
      
    case .backward where UTF8.isContinuation(left.pointee):
      
      moveCodeUnit(.backward)
      move(.backward)
      
    case .forward:
      
      moveCodeUnit(.forward)
      
    case .backward:
      
      moveCodeUnit(.backward)
      
    }
  }
  
  
  private func moveCodeUnit(_ direction: Direction) {
    
    switch direction {
    case .forward:
      
      left += 1
      left.pointee = right.move()
      right += 1
      
    case .backward:
      
      right -= 1
      right.pointee = left.move()
      left -= 1
    }
  }
}

extension GapBuffer {


}


// MARK: - description

extension GapBuffer: CustomStringConvertible, CustomDebugStringConvertible {
  
  var description: String {
    
#if TESTING
    for p in gapStart..<gapEnd {
      p.pointee = "_".utf8.first!
    }
#endif
    
    buffer.append(0)
    defer {
      buffer.removeLast()
    }
    
    return String(validatingUTF8: unsafeBitCast(startAddress, to: UnsafePointer<CChar>.self))!
  }
  
  var debugDescription: String {
    
    var str = ""
    for p in startAddress...left {
      
      str.append(p.pointee.char)
    }
    
    str.append("|")
    
    for p in right...endAddress {
      
      str.append(p.pointee.char)
    }
    
    return str
  }
}


