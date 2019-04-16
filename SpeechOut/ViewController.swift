//
//  ViewController.swift
//  SpeechOut
//
//  Created by David Ilenwabor on 16/04/2019.
//  Copyright © 2019 Davidemi. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController , SFSpeechRecognizerDelegate{

    var speechRecognizerDelegate : SFSpeechRecognizer!
    private let audioEngine = AVAudioEngine()
    @IBOutlet weak var textView: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        speechRecognizerDelegate = SFSpeechRecognizer(locale: Locale.init(identifier: "en_us"))
        speechRecognizerDelegate.delegate = self
        // Do any additional setup after loading the view.
    }
    @IBAction func startRecording(_ sender: UIButton) {
        
        var recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        recognitionRequest.shouldReportPartialResults = true
        let inputNode = configureAudioSession()
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try! audioEngine.start()
        
        var recognitionTask = speechRecognizerDelegate.recognitionTask(with: recognitionRequest) { (result, error) in
            var isFinal = false
            
            if let result = result {
                // Update the text view with the results.
                self.textView.text = result.bestTranscription.formattedString
                isFinal = result.isFinal
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                //recognitionRequest = nil
                //recognitionTask = nil
                
                //self.recordButton.isEnabled = true
                //serecordButton.setTitle("Start Recording", for: [])
            }
        }
    }
    
    private func configureAudioSession()-> AVAudioInputNode{
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try! audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        return audioEngine.inputNode
        
    }
    

}

