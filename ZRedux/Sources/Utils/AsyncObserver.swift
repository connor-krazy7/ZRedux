//
//  AsyncObserver.swift
//  ZRedux
//
//  Created by Artsem Hotsau on 3.06.25.
//

import Foundation

public actor AsyncObserver<T: Sendable> {
  private let bufferSize: Int
  private var buffer: [T] = []
  private var idToStreamContinuation: [UUID: AsyncStream<T>.Continuation] = [:]
  
  public init(bufferSize: Int) {
    self.bufferSize = bufferSize
  }
  
  deinit {
    idToStreamContinuation.values.forEach { $0.finish() }
  }
  
  private func removeStreamContinuation(id: UUID) {
    idToStreamContinuation[id] = nil
  }
  
  public func values() -> AsyncStream<T> {
    let id = UUID()
    let (stream, continuation) = AsyncStream.makeStream(of: T.self, bufferingPolicy: .bufferingNewest(bufferSize))
    continuation.onTermination = { [weak self] _ in
      Task { await self?.removeStreamContinuation(id: id) }
    }
    for value in buffer { continuation.yield(value) }
    idToStreamContinuation[id] = continuation
    return stream
  }
  
  public func publishValue(_ value: T) {
    buffer.append(value)
    
    if buffer.count > bufferSize {
      buffer.removeFirst()
    }
    
    for streamContinuation in idToStreamContinuation.values { streamContinuation.yield(value) }
  }
}
