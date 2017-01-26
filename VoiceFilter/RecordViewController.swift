//
//  ViewController.swift
//  VoiceFilter
//
//  Created by Hector Montero on 12/27/16.
//  Copyright © 2016 Hector Montero. All rights reserved.
//

import UIKit
import AVFoundation

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    var audioRecorder:AVAudioRecorder!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        enableButtons(isRecordButtonEnabled: true, isStopButtonEnabled: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        enableButtons(isRecordButtonEnabled: true, isStopButtonEnabled: false)
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        enableButtons(isRecordButtonEnabled: false, isStopButtonEnabled: true)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordFileName = "recordedVoice.wav"
        let filePath = URL(fileURLWithPath: "\(dirPath)/\(recordFileName)")
        print(filePath)
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(url: filePath, format: AVAudioFormat(settings: [:]))
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        enableButtons(isRecordButtonEnabled: false, isStopButtonEnabled: false)
        
        audioRecorder.stop()
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        
        let playAudioVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PlayAudioViewController") as! PlayAudioViewController
        
        playAudioVC.recordedAudioURL = audioRecorder.url
        
        self.present(playAudioVC, animated: true, completion: nil)
    }
    
    func enableButtons(isRecordButtonEnabled: Bool, isStopButtonEnabled: Bool) {
        recordButton.isEnabled = isRecordButtonEnabled
        stopButton.isEnabled = isStopButtonEnabled
    }
}

