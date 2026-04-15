//
//  RoomViewController.swift
//  WDLive
//
//  Created by scott on 2024/12/7.
//

import UIKit

class RoomViewController: UIViewController {

    @IBOutlet weak var testDigitLabel: GiftDigitLabel!
    @IBOutlet weak var giftHitsContainerView: GiftHitsContainerView!
    let cell = GiftHitsCellView.loadNibView()

    private let livePlayerView = LivePlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        livePlayerView.play(url: LivePlayerView.defaultHLSURL)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        livePlayerView.stop()
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    func setupUI() {
        livePlayerView.frame = view.bounds
        livePlayerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(livePlayerView, at: 0)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        testDigitLabel.performAnimation {
//            print("动画结束")
//        }

    }
    @IBAction func sendGift1Action(_ sender: Any) {
        let giftModel = GiftModel(username: "scott1", name: "大炮", pic: "pking", id: 1, sendCount: 1)
        giftHitsContainerView.show(giftModel)
    }
    @IBAction func sendGift2Action(_ sender: Any) {
        let giftModel = GiftModel(username: "scott2", name: "飞机", pic: "stream", id: 2, sendCount: 2)
        giftHitsContainerView.show(giftModel)
    }
    @IBAction func sendGift3Action(_ sender: Any) {
        let giftModel = GiftModel(username: "scott3", name: "火箭", pic: "video_roomsource_tag", id: 3, sendCount: 3)
        giftHitsContainerView.show(giftModel)
    }
}

extension RoomViewController {
     @IBAction func onBackButtonClick(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onBottomButtonClick(_ sender: Any) {
        let button = sender as! UIButton
        switch button.tag {
        case 0:
            let request = MusicRequest(keywords: "海阔天空")
            WDRequestClient().send(request) { result in
                switch result {
                case .success(let songList):
                    print(songList ?? "error")
                case .failure(let error):
                    print(error)
                }
            }
        case 1:
            showRedPackagePopupDemo()
        case 2:
            break
        case 3:
            button.isSelected = !button.isSelected
            if button.isSelected {
                startEmitter()
            } else {
                stopEmitter()
            }
        default:
            break
        }
   }
}

extension RoomViewController: EmitterEnableProtocol {

}
