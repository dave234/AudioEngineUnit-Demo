import AudioKit

class DelayedReverbAudioUnit: AudioEngineUnit {

    private let delay = AVAudioUnitDelay()
    private let reverb = AVAudioUnitReverb()
    private let reverbMixer = AVAudioMixerNode()
    private enum Bus: AVAudioNodeBus {
        case through = 0
        case reverb = 1
    }

    public var wetDryMix: AudioUnitParameterValue = 50.0 {
        didSet {
            let clamped = max(0, min(wetDryMix, 100))
            guard clamped == wetDryMix else { return wetDryMix = clamped }

            let ratio = wetDryMix / 100
            reverbMixer.volume = ratio
            audioEngine.inputNode.volume = 1 - ratio
        }
    }

    public var delayTime: TimeInterval = 1 {
        didSet { delay.delayTime = delayTime }
    }

    override func allocateRenderResources() throws {

        audioEngine.attach(delay)
        audioEngine.attach(reverb)
        audioEngine.attach(reverbMixer)
        let format = outputBusses[0].format

        let connectionPoints = [AVAudioConnectionPoint(node: audioEngine.mainMixerNode, bus: 0),
                                AVAudioConnectionPoint(node: delay,                     bus: 0)]

        audioEngine.connect(audioEngine.inputNode, to: connectionPoints, fromBus: 0, format: format)

        audioEngine.connect(delay,                  to: reverb,                     format: format)
        audioEngine.connect(reverb,                 to: reverbMixer,                format: format)
        audioEngine.connect(reverbMixer,            to: audioEngine.mainMixerNode,  format: format)

        reverb.wetDryMix = 100
        delay.wetDryMix = 100

        let ratio = wetDryMix / 100
        reverbMixer.volume = ratio
        audioEngine.inputNode.volume = 1 - ratio

        // Was getting errors when this was at top of function, kinda smelly :(
        // We may need to create an override function in the base class - something like prepareInternalNodes()
        try super.allocateRenderResources()

    }
}


class DelayedReverbNode {

    private let auAudioUnit: DelayedReverbAudioUnit
    private let avAudioUnit: AVAudioUnit

    init() {
        (self.avAudioUnit, self.auAudioUnit) = AudioUnitFactory<DelayedReverbAudioUnit>.create(type: .effect, subType: "rdly", manufacturer: "onil")
        wetDryMix = auAudioUnit.wetDryMix
        delayTime = auAudioUnit.delayTime
    }

    public var wetDryMix: AudioUnitParameterValue {
        didSet { auAudioUnit.wetDryMix = wetDryMix }
    }

    public var delayTime: TimeInterval {
        didSet { auAudioUnit.delayTime = delayTime }
    }
}

extension DelayedReverbNode: AKInput {
    var outputNode: AVAudioNode { return avAudioUnit }
    var inputNode:  AVAudioNode { return avAudioUnit }
}
