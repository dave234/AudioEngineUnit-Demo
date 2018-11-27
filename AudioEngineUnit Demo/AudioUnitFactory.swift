import AudioKit


class AudioUnitFactory<T> where T: AUAudioUnit {

    enum ComponentType {
        case output
        case musicDevice
        case musicEffect
        case formatConverter
        case effect
        case mixer
        case panner
        case generator
        case offlineEffect
        case midiProcessor

        var osType: OSType {
            switch self {
            case .output:           return kAudioUnitType_Output
            case .musicDevice:      return kAudioUnitType_MusicDevice
            case .musicEffect:      return kAudioUnitType_MusicEffect
            case .formatConverter:  return kAudioUnitType_FormatConverter
            case .effect:           return kAudioUnitType_Effect
            case .mixer:            return kAudioUnitType_Mixer
            case .panner:           return kAudioUnitType_Panner
            case .generator:        return kAudioUnitType_Generator
            case .offlineEffect:    return kAudioUnitType_OfflineEffect
            case .midiProcessor:    return kAudioUnitType_MIDIProcessor
            }
        }
    }


    static func create(name: String? = nil, type: ComponentType, subType fourCCSubtype: String, manufacturer fourCCManufacturer: String) -> (AVAudioUnit, T) {
        
        let componentDescription = AudioComponentDescription(componentType: type.osType,
                                                             componentSubType: fourCC(fourCCSubtype),
                                                             componentManufacturer: fourCC(fourCCManufacturer),
                                                             componentFlags: 0,
                                                             componentFlagsMask: 0)

        AUAudioUnit.registerSubclass(T.self, as: componentDescription, name: name ?? String(describing: T.self), version: 1)

        var outUnit: AVAudioUnit?

        let disptachGroup = DispatchGroup()
        disptachGroup.enter()
        AVAudioUnit.instantiate(with: componentDescription) { (avAudioUnit, error) in
            outUnit = avAudioUnit
            disptachGroup.leave()
        }
        disptachGroup.wait()

        guard let avAudioUnit = outUnit,
            let auAUdioUnit = avAudioUnit.auAudioUnit as? T else {
                fatalError()
        }
        return (avAudioUnit, auAUdioUnit)
    }

}
