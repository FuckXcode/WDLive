//
//  LivePlayerView.swift
//  WDLive
//

import UIKit
import AVFoundation
import HaishinKit

// swiftlint:disable line_length
final class LivePlayerView: UIView {

    // MARK: - Public test stream URLs
    static let defaultHLSURL = URL(string: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8")!
    static let defaultRTMPURL = URL(string: "rtmp://liteavapp.qcloud.com/live/streamid")!

    // MARK: - Private
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var rtmpConnection: RTMPConnection?
    private var rtmpStream: RTMPStream?
    private var rtmpStreamView: MTHKView?
    private var pendingStreamName: String = ""

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
        rtmpStreamView?.frame = bounds
    }

    // MARK: - Public API

    func play(url: URL) {
        stop()
        if url.scheme?.lowercased() == "rtmp" {
            playRTMP(url: url)
        } else {
            playHLS(url: url)
        }
    }

    func stop() {
        player?.pause()
        playerLayer?.removeFromSuperlayer()
        player = nil
        playerLayer = nil

        rtmpConnection?.removeEventListener(.rtmpStatus, selector: #selector(handleRTMPStatus(_:)), observer: self)
        rtmpStream?.close()
        rtmpConnection?.close()
        rtmpStreamView?.removeFromSuperview()
        rtmpStream = nil
        rtmpConnection = nil
        rtmpStreamView = nil
    }

    // MARK: - HLS

    private func playHLS(url: URL) {
        let avPlayer = AVPlayer(url: url)
        player = avPlayer
        let layer = AVPlayerLayer(player: avPlayer)
        layer.frame = bounds
        layer.videoGravity = .resizeAspectFill
        self.layer.insertSublayer(layer, at: 0)
        playerLayer = layer
        avPlayer.play()
    }

    // MARK: - RTMP

    private func playRTMP(url: URL) {
        let pathComponents = url.pathComponents.filter { $0 != "/" }
        let app = pathComponents.first ?? "live"
        let streamName = pathComponents.dropFirst().joined(separator: "/")
        pendingStreamName = streamName

        guard let host = url.host else { return }
        let scheme = url.scheme ?? "rtmp"
        let serverURL = "\(scheme)://\(host)/\(app)"

        let connection = RTMPConnection()
        let stream = RTMPStream(connection: connection)
        rtmpConnection = connection
        rtmpStream = stream

        let streamView = MTHKView(frame: bounds)
        streamView.videoGravity = .resizeAspectFill
        streamView.attachStream(stream)
        addSubview(streamView)
        rtmpStreamView = streamView

        connection.addEventListener(.rtmpStatus, selector: #selector(handleRTMPStatus(_:)), observer: self)
        connection.connect(serverURL)
    }

    @objc private func handleRTMPStatus(_ notification: Notification) {
        let event = Event.from(notification)
        guard let data = event.data as? ASObject,
              let codeValue = data["code"],
              let code = codeValue as? String,
              code == RTMPConnection.Code.connectSuccess.rawValue else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.rtmpStream?.play(self.pendingStreamName)
        }
    }
}
