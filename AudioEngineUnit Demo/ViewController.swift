import UIKit
import AudioKit

class ViewController: UIViewController {

    let oscillator = AKOscillator()
    let delayedReverb = DelayedReverbNode()
    let audioKitOutputSetterWorkaroundMixer = AKMixer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // I'd rather that it worked like this:
        // oscillator >>> delayedReverb >>> AudioKit.outputNode

        // rather than this:
        oscillator >>> delayedReverb >>> audioKitOutputSetterWorkaroundMixer
        AudioKit.output = audioKitOutputSetterWorkaroundMixer

        try! AudioKit.start()

        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(buttonDownAction), for: .touchDown)
        button.addTarget(self, action: #selector(buttonUpAction), for: .touchUpInside)
        button.frame = CGRect(origin: .zero, size: CGSize(width: 50, height: 50))
        button.setTitle("Button", for: .normal)

        view.addSubview(button)
        button.center = view.center

    }

    @objc func buttonDownAction() {
        oscillator.start()
    }

    @objc func buttonUpAction() {
        oscillator.stop()
    }

}

