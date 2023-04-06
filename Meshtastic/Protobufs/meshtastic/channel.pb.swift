// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: meshtastic/channel.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

///
/// This information can be encoded as a QRcode/url so that other users can configure
/// their radio to join the same channel.
/// A note about how channel names are shown to users: channelname-X
/// poundsymbol is a prefix used to indicate this is a channel name (idea from @professr).
/// Where X is a letter from A-Z (base 26) representing a hash of the PSK for this
/// channel - so that if the user changes anything about the channel (which does
/// force a new PSK) this letter will also change. Thus preventing user confusion if
/// two friends try to type in a channel name of "BobsChan" and then can't talk
/// because their PSKs will be different.
/// The PSK is hashed into this letter by "0x41 + [xor all bytes of the psk ] modulo 26"
/// This also allows the option of someday if people have the PSK off (zero), the
/// users COULD type in a channel name and be able to talk.
/// FIXME: Add description of multi-channel support and how primary vs secondary channels are used.
/// FIXME: explain how apps use channels for security.
/// explain how remote settings and remote gpio are managed as an example
struct ChannelSettings {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///
  /// Deprecated in favor of LoraConfig.channel_num
  var channelNum: UInt32 = 0

  ///
  /// A simple pre-shared key for now for crypto.
  /// Must be either 0 bytes (no crypto), 16 bytes (AES128), or 32 bytes (AES256).
  /// A special shorthand is used for 1 byte long psks.
  /// These psks should be treated as only minimally secure,
  /// because they are listed in this source code.
  /// Those bytes are mapped using the following scheme:
  /// `0` = No crypto
  /// `1` = The special "default" channel key: {0xd4, 0xf1, 0xbb, 0x3a, 0x20, 0x29, 0x07, 0x59, 0xf0, 0xbc, 0xff, 0xab, 0xcf, 0x4e, 0x69, 0x01}
  /// `2` through 10 = The default channel key, except with 1 through 9 added to the last byte.
  /// Shown to user as simple1 through 10
  var psk: Data = Data()

  ///
  /// A SHORT name that will be packed into the URL.
  /// Less than 12 bytes.
  /// Something for end users to call the channel
  /// If this is the empty string it is assumed that this channel
  /// is the special (minimally secure) "Default"channel.
  /// In user interfaces it should be rendered as a local language translation of "X".
  /// For channel_num hashing empty string will be treated as "X".
  /// Where "X" is selected based on the English words listed above for ModemPreset
  var name: String = String()

  ///
  /// Used to construct a globally unique channel ID.
  /// The full globally unique ID will be: "name.id" where ID is shown as base36.
  /// Assuming that the number of meshtastic users is below 20K (true for a long time)
  /// the chance of this 64 bit random number colliding with anyone else is super low.
  /// And the penalty for collision is low as well, it just means that anyone trying to decrypt channel messages might need to
  /// try multiple candidate channels.
  /// Any time a non wire compatible change is made to a channel, this field should be regenerated.
  /// There are a small number of 'special' globally known (and fairly) insecure standard channels.
  /// Those channels do not have a numeric id included in the settings, but instead it is pulled from
  /// a table of well known IDs.
  /// (see Well Known Channels FIXME)
  var id: UInt32 = 0

  ///
  /// If true, messages on the mesh will be sent to the *public* internet by any gateway ndoe
  var uplinkEnabled: Bool = false

  ///
  /// If true, messages seen on the internet will be forwarded to the local mesh.
  var downlinkEnabled: Bool = false

  var unknownFields = SwiftProtobuf.UnknownStorage()

  init() {}
}

///
/// A pair of a channel number, mode and the (sharable) settings for that channel
struct Channel {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  ///
  /// The index of this channel in the channel table (from 0 to MAX_NUM_CHANNELS-1)
  /// (Someday - not currently implemented) An index of -1 could be used to mean "set by name",
  /// in which case the target node will find and set the channel by settings.name.
  var index: Int32 = 0

  ///
  /// The new settings, or NULL to disable that channel
  var settings: ChannelSettings {
    get {return _settings ?? ChannelSettings()}
    set {_settings = newValue}
  }
  /// Returns true if `settings` has been explicitly set.
  var hasSettings: Bool {return self._settings != nil}
  /// Clears the value of `settings`. Subsequent reads from it will return its default value.
  mutating func clearSettings() {self._settings = nil}

  ///
  /// TODO: REPLACE
  var role: Channel.Role = .disabled

  var unknownFields = SwiftProtobuf.UnknownStorage()

  ///
  /// How this channel is being used (or not).
  /// Note: this field is an enum to give us options for the future.
  /// In particular, someday we might make a 'SCANNING' option.
  /// SCANNING channels could have different frequencies and the radio would
  /// occasionally check that freq to see if anything is being transmitted.
  /// For devices that have multiple physical radios attached, we could keep multiple PRIMARY/SCANNING channels active at once to allow
  /// cross band routing as needed.
  /// If a device has only a single radio (the common case) only one channel can be PRIMARY at a time
  /// (but any number of SECONDARY channels can't be sent received on that common frequency)
  enum Role: SwiftProtobuf.Enum {
    typealias RawValue = Int

    ///
    /// This channel is not in use right now
    case disabled // = 0

    ///
    /// This channel is used to set the frequency for the radio - all other enabled channels must be SECONDARY
    case primary // = 1

    ///
    /// Secondary channels are only used for encryption/decryption/authentication purposes.
    /// Their radio settings (freq etc) are ignored, only psk is used.
    case secondary // = 2
    case UNRECOGNIZED(Int)

    init() {
      self = .disabled
    }

    init?(rawValue: Int) {
      switch rawValue {
      case 0: self = .disabled
      case 1: self = .primary
      case 2: self = .secondary
      default: self = .UNRECOGNIZED(rawValue)
      }
    }

    var rawValue: Int {
      switch self {
      case .disabled: return 0
      case .primary: return 1
      case .secondary: return 2
      case .UNRECOGNIZED(let i): return i
      }
    }

  }

  init() {}

  fileprivate var _settings: ChannelSettings? = nil
}

#if swift(>=4.2)

extension Channel.Role: CaseIterable {
  // The compiler won't synthesize support with the UNRECOGNIZED case.
  static var allCases: [Channel.Role] = [
    .disabled,
    .primary,
    .secondary,
  ]
}

#endif  // swift(>=4.2)

#if swift(>=5.5) && canImport(_Concurrency)
extension ChannelSettings: @unchecked Sendable {}
extension Channel: @unchecked Sendable {}
extension Channel.Role: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "meshtastic"

extension ChannelSettings: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".ChannelSettings"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .standard(proto: "channel_num"),
    2: .same(proto: "psk"),
    3: .same(proto: "name"),
    4: .same(proto: "id"),
    5: .standard(proto: "uplink_enabled"),
    6: .standard(proto: "downlink_enabled"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularUInt32Field(value: &self.channelNum) }()
      case 2: try { try decoder.decodeSingularBytesField(value: &self.psk) }()
      case 3: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 4: try { try decoder.decodeSingularFixed32Field(value: &self.id) }()
      case 5: try { try decoder.decodeSingularBoolField(value: &self.uplinkEnabled) }()
      case 6: try { try decoder.decodeSingularBoolField(value: &self.downlinkEnabled) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    if self.channelNum != 0 {
      try visitor.visitSingularUInt32Field(value: self.channelNum, fieldNumber: 1)
    }
    if !self.psk.isEmpty {
      try visitor.visitSingularBytesField(value: self.psk, fieldNumber: 2)
    }
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 3)
    }
    if self.id != 0 {
      try visitor.visitSingularFixed32Field(value: self.id, fieldNumber: 4)
    }
    if self.uplinkEnabled != false {
      try visitor.visitSingularBoolField(value: self.uplinkEnabled, fieldNumber: 5)
    }
    if self.downlinkEnabled != false {
      try visitor.visitSingularBoolField(value: self.downlinkEnabled, fieldNumber: 6)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: ChannelSettings, rhs: ChannelSettings) -> Bool {
    if lhs.channelNum != rhs.channelNum {return false}
    if lhs.psk != rhs.psk {return false}
    if lhs.name != rhs.name {return false}
    if lhs.id != rhs.id {return false}
    if lhs.uplinkEnabled != rhs.uplinkEnabled {return false}
    if lhs.downlinkEnabled != rhs.downlinkEnabled {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Channel: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  static let protoMessageName: String = _protobuf_package + ".Channel"
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "index"),
    2: .same(proto: "settings"),
    3: .same(proto: "role"),
  ]

  mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularInt32Field(value: &self.index) }()
      case 2: try { try decoder.decodeSingularMessageField(value: &self._settings) }()
      case 3: try { try decoder.decodeSingularEnumField(value: &self.role) }()
      default: break
      }
    }
  }

  func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if self.index != 0 {
      try visitor.visitSingularInt32Field(value: self.index, fieldNumber: 1)
    }
    try { if let v = self._settings {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 2)
    } }()
    if self.role != .disabled {
      try visitor.visitSingularEnumField(value: self.role, fieldNumber: 3)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  static func ==(lhs: Channel, rhs: Channel) -> Bool {
    if lhs.index != rhs.index {return false}
    if lhs._settings != rhs._settings {return false}
    if lhs.role != rhs.role {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Channel.Role: SwiftProtobuf._ProtoNameProviding {
  static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    0: .same(proto: "DISABLED"),
    1: .same(proto: "PRIMARY"),
    2: .same(proto: "SECONDARY"),
  ]
}
