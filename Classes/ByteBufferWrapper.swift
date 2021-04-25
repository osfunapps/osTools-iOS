//
//  ByteBufferWrapper.swift
//  OsTools
//
//  Created by Oz Shabat on 25/04/2021.
//

import Foundation

/// Just a simple bye buffer. Init to read/write to/from bytes (readUint16, writeUint16 and more...)
public class ByteBufferWrapper {
    
    var _packet: [UInt8]!
    private var _totalLength: Int!
    var _offset = 0
    
    init(packet: [UInt8] = [UInt8]()) {
        self._packet = packet
        _totalLength = packet.count
        _offset = 0
    }
    
    
    // MARK: - write
    
    func writeBytes (data: [UInt8]? = nil, type: Any? = nil) -> [UInt8]? {
        if let _data = data {
            self._add(data: _data)
        }

        return data
    }
    
    /// will write a string to the packet
    func writeSGString(data: String) {
        let uInt8Value0 = UInt8(data.count >> 8)
        let uInt8Value1 = UInt8(data.count & 0x00ff)
        let lengthBuffer: [UInt8] = [uInt8Value0, uInt8Value1]
        
        let buf = [UInt8](data.utf8)
        let addon: [UInt8] = [0]
        let dataBuffer = buf + addon
        let ans = lengthBuffer + dataBuffer
        self._add(data: ans);
    }
    
    
    
    /// will write a single byte to the buffer
    func writeUInt8(data: Int?) {
        var bytes = [UInt8]()
        if let _data = data {
            let uInt8Value0 = UInt8(_data)
            bytes = [uInt8Value0]
            _add(data: bytes)
        }
    }

    
    /// will write 2 bytes to the packet
    func writeUInt16(data: Int?) {
        var bytes = [UInt8]()
        if let _data = data {
            let uInt8Value0 = UInt8(_data >> 8)
            let uInt8Value1 = UInt8(_data & 0x00ff)
            bytes = [uInt8Value0, uInt8Value1]
        } else {
            bytes = [0,0]
        }
        _add(data: bytes)
    }
    
    /// will write 8 bytes to the packet
    func writeUInt64LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        let byte3 = UInt8(value >> 16 & 0xff)
        let byte4 = UInt8(value >> 24 & 0xff)
        let byte5 = UInt8(value >> 32 & 0xff)
        let byte6 = UInt8(value >> 40 & 0xff)
        let byte7 = UInt8(value >> 48 & 0xff)
        let byte8 = UInt8(value >> 56 & 0xff)
        self._add(data: [byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8])
//        self._add(data: [byte8, byte7, byte6, byte5, byte4, byte3, byte2, byte1])
    }
    
    
    /// will write 4 bytes to the packet
    func writeUInt32(data: Int?) {
        var bytes = [UInt8]()
        if let _data = data {
            let __data = UInt32(_data)
            let byte1 = UInt8(_data & 0x000000FF)         // 10
            let byte2 = UInt8((_data & 0x0000FF00) >> 8)  // 154
            let byte3 = UInt8((_data & 0x00FF0000) >> 16) // 0
            let intt = (__data & (0xFF000000 as UInt32))
            let byte4 = UInt8(intt >> 24) // 0
            bytes = [byte4, byte3, byte2, byte1]
        } else {
            bytes = [0,0,0,0]
        }
        _add(data: bytes)
        //        self._packet = self._packet + bytes
    }
    
    func writeUInt32LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        let byte3 = UInt8(value >> 16 & 0xff)
        let byte4 = UInt8(value >> 24 & 0xff)
        self._add(data: [byte1, byte2, byte3, byte4])
    }
    
    func writeUInt16LE(value: Int) {
        let byte1 = UInt8(value & 0xff)
        let byte2 = UInt8(value >> 8 & 0xff)
        self._add(data: [byte1, byte2])
    }
    
    
    func writeFloat32LE(valToAdd: Float) {
        writeUInt32LE(value: Int(valToAdd.bitPattern))
    }
    
    // MARK: - read
    
    
      /// will read a string from the packet
      func readSGString() -> String? {
          
          guard let dataLength = self.readUInt16() else {
              return nil
          }
          if self._offset > _packet.count || self._offset + Int(dataLength) > self._packet.count {
              return nil
          }
          
          let data = self._packet.slice(self._offset, self._offset + Int(dataLength));
          self._offset = (self._offset + 1 + Int(dataLength));
          return data.toUTFString()!
      }
      
      func readLESGString() -> String {
          let dataLength = Int(self.readUInt16LE())
          let data = self._packet.slice(self._offset, self._offset + dataLength);
          
          self._offset = self._offset + dataLength;
          return data.toUTFString()!
      }
      
      
      
      /// will read bytes from the packet
      func readBytes(count: Int? = 0) -> [UInt8] {
          var data: [UInt8] = [];
          if(count == nil || count! == 0){
              data = self._packet.slice(self._offset);
              self._offset = (self._totalLength);
          } else {
              data = self._packet.slice(self._offset, self._offset+count!);
              self._offset = (self._offset+count!);
          }
          
          return data;
      }
      
     
      
      /// will read a single byte from the buffer
      func readUInt8() -> UInt8? {
          if self._offset > _packet.count {
              return nil
          }
          let bigEndianValue = _packet.slice(self._offset).withUnsafeBufferPointer {
              ($0.baseAddress!.withMemoryRebound(to: UInt8.self, capacity: 1) { $0 })
              }.pointee
          self._offset += 1
          let ans = UInt8(bigEndian: bigEndianValue)
          return ans
      }

      
      
      /// Method to get a UInt16 from two bytes in the byte array (little-endian).
      public func readUInt16() -> UInt16? {
          if self._offset > _packet.count {
              return nil
          }
          let bigEndianValue = _packet.slice(self._offset).withUnsafeBufferPointer {
              ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
              }.pointee
          self._offset += 2
          return UInt16(bigEndian: bigEndianValue)
      }
      

      
      /// will read 4 bytes from the packet
      func readUInt32() -> UInt32? {
          if self._offset > _packet.count {
              return nil
          }
          let bigEndianValue = _packet.slice(self._offset).withUnsafeBufferPointer {
              ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
              }.pointee
          self._offset += 4
          return UInt32(bigEndian: bigEndianValue)
      }

    
    func readFloat32LE() -> Float? {
        guard let ans = readUInt32() else {
            return nil
        }
        return Float.init(bitPattern: ans)
    }
    
    func readUInt16LE() -> Int {
        let uint16Val = _packet.slice(self._offset).withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt16.self, capacity: 1) { $0 })
            }.pointee
        self._offset += 2
        return Int(UInt16(littleEndian: uint16Val))
    }
    
    func readUInt32LE() -> Int {
        let uint32Val = _packet.slice(self._offset).withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt32.self, capacity: 1) { $0 })
            }.pointee
        self._offset += 4
        
        return Int(UInt32(littleEndian: uint32Val))
    }
    
    func readUInt64LE() -> Int {
        let uint64Val = _packet.slice(self._offset).withUnsafeBufferPointer {
            ($0.baseAddress!.withMemoryRebound(to: UInt64.self, capacity: 1) { $0 })
            }.pointee
        self._offset += 8
        
        return Int(UInt64(littleEndian: uint64Val))
    }
    
    
    // MARK: - others
    
    private func _add(data: [UInt8]) {
        self._packet = self._packet + data
    }
    
    func toBuffer() -> [UInt8] {
        return self._packet
    }
}
