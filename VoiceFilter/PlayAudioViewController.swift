//
//  PlayAudioViewController.swift
//  VoiceFilter
//
//  Created by Hector Montero on 12/27/16.
//  Copyright © 2016 Hector Montero. All rights reserved.
//

import UIKit
import AVFoundation

class PlayAudioViewController: UIViewController {
    
    var recordedAudioURL : URL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    @IBOutlet weak var chipmunkButton: UIButton!
    @IBOutlet weak var darthVaderButton: UIButton!
    @IBOutlet weak var echoButton: UIButton!
    @IBOutlet weak var rabbitButton: UIButton!
    @IBOutlet weak var reverbButton: UIButton!
    @IBOutlet weak var snailButton: UIButton!
    @IBOutlet weak var recordAgainButton: UIButton!
    
    enum ButtonType: Int {case slow = 0, fast, chipmunk, vader, echo, reverb }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI(.notPlaying)
    }
    
    @IBAction func playAudio(_ sender: UIButton!) {
        switch (sender) {
        case chipmunkButton:
            playAudio(pitch: 1000)
        case darthVaderButton:
            playAudio(pitch: -1000)
        case echoButton:
            playAudio(echo: true)
        case rabbitButton:
            playAudio(rate: 1.5)
        case reverbButton:
            playAudio(reverb: true)
        case snailButton:
            playAudio(rate: 0.5)
        default:
            playAudio(rate: 1, pitch: 1, echo: false, reverb: false)
        }
        
        configureUI(.playing)
    }
    
    @IBAction func recordAgain(_ sender: UIButton!) {
        stopAudio()
        dismiss(animated: true, completion: nil)
    }
    
}
