//
//  AudioManager.swift
//  VoiceFilter
//
//  Created by Hector Montero on 12/27/16.
//  Copyright © 2016 Hector Montero. All rights reserved.
//

import UIKit
import AVFoundation

extension PlayAudioViewController: AVAudioPlayerDelegate {
    
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    // raw values correspond to sender tags
    enum PlayingState { case playing, notPlaying }
    
    func setupAudio() {
        do {
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        } catch {
            showAlert(Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playAudio(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false) {
        audioEngine = AVAudioEngine()
        
        audioPlayerNode = AVAudioPlayerNode()
        audioEngine.attach(audioPlayerNode)
        
        let changeRatePitchNode = AVAudioUnitTimePitch()
        if let pitch = pitch {
            changeRatePitchNode.pitch = pitch
        }
        if let rate = rate {
            changeRatePitchNode.rate = rate
        }
        audioEngine.attach(changeRatePitchNode)
        
        let echoNode = AVAudioUnitDistortion()
        echoNode.loadFactoryPreset(.multiEcho1)
        audioEngine.attach(echoNode)
        
        let reverbNode = AVAudioUnitReverb()
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        
        if echo && reverb {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        } else if echo {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        } else if reverb {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        } else {
            connectAudioNodes(audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }
        
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil, completionHandler: {
            var delayInSeconds: Double = 0
            
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime,
                let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime) {
            
                if let rate = rate {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                    
                } else {
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }
            
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlayAudioViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer, forMode: RunLoopMode.defaultRunLoopMode)
        })
        
        do {
            try audioEngine.start()
        } catch {
            showAlert(Alerts.AudioEngineError, message: String(describing: error))
        }
        
        audioPlayerNode.play()
    }
    
    func stopAudio() {
        if let stopTimer = stopTimer {
            stopTimer.invalidate()
        }
        
        configureUI(.notPlaying)
        
        if let audioPlayerNode = audioPlayerNode {
            audioPlayerNode.stop()
        }
        
        if let audioEngine = audioEngine {
            audioEngine.stop()
            audioEngine.reset()
        }
    }
    
    func configureUI(_ playState: PlayingState) {
        switch(playState) {
        case .playing:
            setPlayButtonsEnabled(false)
            recordAgainButton.isEnabled = false
        case .notPlaying:
            setPlayButtonsEnabled(true)
            recordAgainButton.isEnabled = true
        }
    }
    
    func setPlayButtonsEnabled(_ enabled: Bool) {
        snailButton.isEnabled = enabled
        chipmunkButton.isEnabled = enabled
        rabbitButton.isEnabled = enabled
        darthVaderButton.isEnabled = enabled
        echoButton.isEnabled = enabled
        reverbButton.isEnabled = enabled
    }

    
    func connectAudioNodes(_ nodes: AVAudioNode...) {
        for x in 0..<(nodes.count - 1) {
            audioEngine.connect(nodes[x], to: nodes[x + 1], format: audioFile.processingFormat)
        }
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


