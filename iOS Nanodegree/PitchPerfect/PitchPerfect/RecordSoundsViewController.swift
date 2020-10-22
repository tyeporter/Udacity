//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Tye Porter on 3/27/20.
//  Copyright © 2020 Tye Porter. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    // TODO: Add Support For iOS 12 and earlier
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var pulsingView: UIView!
    @IBOutlet weak var trackView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    enum RecordState { case recording, notRecording }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Setup navbar
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI(RecordState.notRecording)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Audio Recorder

    @IBAction func recordAudio(_ sender: Any) {
        configureUI(RecordState.recording)
        
        // Create file path to store audio file
        let dirPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0] as String // (Finds application's Document directory)
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        // Setup an audio session (needed to record or playback audio)
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        // Try to create an audio recorder
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        
        // Setup audio recorder and record
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    @IBAction func stopRecording(_ sender: Any) {   // Former @IBAction
        configureUI(RecordState.notRecording)
        
        // Stop audio recorder
        audioRecorder.stop()
        
        // Deactivate audio session
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: - Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    // MARK: Storyboard
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    // MARK: - Helper Methods
    
    func configureUI(_ recordState: RecordState) {
        switch recordState {
        case .recording:
            recordButton.isEnabled = false
            stopRecordingButton.isEnabled = true
            trackView.backgroundColor = UIColor.rgb(r: 217, g: 41, b: 56)
            animatePulsatingLayer()
            recordingLabel.text = "Recording in Progress"
        case .notRecording:
            recordButton.isEnabled = true
            stopRecordingButton.isEnabled = false
            trackView.backgroundColor = UIColor.rgb(r: 100, g: 100, b: 100)
            pulsingView.layer.removeAllAnimations()
            recordingLabel.text = "Tap to Record"
        }
    }
    
    func setupNavigationBar() {
        // Set navbar tint
        navigationController?.navigationBar.barTintColor = UIColor.rgb(r: 3, g: 4, b: 6)
        
        // Set navbar title
        navigationItem.title = "Pitch Perfect"
        
        // Set navbar title color
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.rgb(r: 137, g: 137, b: 137)
        ]
    }
    
    // Pulsing animation idea from:
    // https://www.letsbuildthatapp.com/course_video?id=2362 (Make your App Come Alive - Pulsing Animation)
    
    private func animatePulsatingLayer() {
        UIView.animate(withDuration: 0.8, delay: 0, options: [.curveEaseOut, .autoreverse, .repeat], animations: {
            self.pulsingView.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }, completion: { (finished) in
            self.pulsingView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        })
    }
}


