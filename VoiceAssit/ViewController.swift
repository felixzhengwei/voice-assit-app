//
//  ViewController.swift
//  VoiceAssit
//
//  Created by Felix Wei on 2017-02-23.
//  Copyright © 2017 Felix Wei. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

class ViewController: UIViewController, SFSpeechRecognizerDelegate, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var messageView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    var audioRecorder: AVAudioRecorder!
    var levelTimer = Timer()
    var isCounterRunning = false
    var lowPassResults: Double = 0.0
    
    var seconds = 3
    var timer = Timer()
    var isTimerRunning = false
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1
    
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
        microphoneButton.layer.cornerRadius = 8
        recordingLabel.layer.masksToBounds = true
        recordingLabel.layer.cornerRadius = 8
        confirmButton.layer.cornerRadius = 8
        backButton.layer.cornerRadius = 8
        
        microphoneButton.isEnabled = false  //2
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.3
        
        speechRecognizer!.delegate = self  //3
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            var isButtonEnabled = false
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
                
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
                
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
                
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
            
            OperationQueue.main.addOperation() {
                self.microphoneButton.isEnabled = isButtonEnabled
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func microphoneTapped(_ sender: AnyObject) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Start Recording", for: .normal)
            audioRecorder!.stop()
            self.levelTimer.invalidate()
            isTimerRunning = false
            seconds = 3
        } else {
            startRecording()
            
            microphoneButton.setTitle("Stop Recording", for: .normal)
        }
        
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        Helper.postRequest(message: messageView.text)
    }
    
    
    func startRecording() {
        
        
        let fileMgr = FileManager.default
        
        let dirPaths = fileMgr.urls(for: .documentDirectory,
                                    in: .userDomainMask)
        
        let soundFileURL = dirPaths[0].appendingPathComponent("sound.caf")
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        do {
            try audioRecorder = AVAudioRecorder(url: soundFileURL, settings: settings)
            audioRecorder!.prepareToRecord();
            audioRecorder!.delegate = self
            audioRecorder!.record();
            audioRecorder!.isMeteringEnabled = true;
            if isTimerRunning == false {
                runTimer()
            }
            
        } catch let error as NSError {
            print("audioSession error: \(error.localizedDescription)")
        }
        
        
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
        }
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer!.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            
            if result != nil {
                
                self.messageView.text = result?.bestTranscription.formattedString
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self.isTimerRunning = false
                self.seconds = 3
                self.recognitionRequest = nil
                self.recognitionTask = nil
                self.confirmButton.isEnabled = true
                self.microphoneButton.isEnabled = true
                self.confirmButton.alpha = 1
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
        
        messageView.text = ""
        confirmButton.isEnabled = false
        confirmButton.alpha = 0.3
        
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            microphoneButton.isEnabled = true
        } else {
            microphoneButton.isEnabled = false
        }
    }
    
    func levelTimerCallback() {
        //we have to update meters before we can get the metering values
        audioRecorder.updateMeters()
        print(audioRecorder.averagePower(forChannel: 0))
        //terminate recording if the audio levels drops to beginning range
        if (audioRecorder.averagePower(forChannel: 0) < -40 && audioRecorder.averagePower(forChannel: 0) > -90) {
            
            audioEngine.stop()
            recognitionRequest?.endAudio()
            microphoneButton.isEnabled = false
            microphoneButton.setTitle("Say it Again ", for: .normal)
            audioRecorder!.stop()
            confirmButton.isEnabled = true
            confirmButton.alpha = 1
            
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self,   selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        isTimerRunning = true
        if isCounterRunning {
            levelTimer.invalidate()
            isCounterRunning = false
        }
    }
    
    func updateTimer() {
        if seconds < 1 {
            timer.invalidate()
            isCounterRunning = true
            levelTimer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(ViewController.levelTimerCallback), userInfo: nil, repeats: true)
        } else {
            seconds -= 1
            
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

