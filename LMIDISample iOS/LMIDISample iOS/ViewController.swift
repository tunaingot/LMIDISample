//
//  ViewController.swift
//  LMIDISample iOS
//
//  Created by 大川 博 on 2025/04/29.
//

import UIKit
import MIDIFramework

class ViewController: UIViewController {
    @IBOutlet weak var noteButton: UIButton!
    @IBOutlet weak var previewButton: UIButton!
    
    private var midiDevice: LMIDI?
    
    /*==========================================================================
     
     =========================================================================*/
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(LMIDI.sourceNames)                                                                    //接続されている送信MIDIデバイス全てを表示する
        print(LMIDI.destinationNames)                                                               //接続されている受信MIDIデバイス全てを表示する

        if LMIDI.sourceNames.isEmpty || LMIDI.destinationNames.isEmpty {                            //MIDIデバイスが存在しない
            print("MIDIデバイスを接続してください")
        } else {
            midiDevice = LMIDI(sourceName: LMIDI.sourceNames.last!,                                 //MIDIデバイスのインスタンスを生成する
                               destinationName: LMIDI.destinationNames.last!)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(messageReceived(_:)),            //全ての受信通知を受け取る
                                                   name: LMIDI.messageReceivedNotification,
                                                   object: midiDevice)
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(controlChangeReceived(_:)),  //コントロールチェンジ受信通知を受け取る
                                                   name: LMIDI.controlChangeReceivedNotification,
                                                   object: midiDevice)
        }
    }


}

//MARK: - action & notification
extension ViewController {
    //MARK: - button action
    /*==========================================================================
     
     =========================================================================*/
    @IBAction func noteButton(_ sender: Any) {
        midiDevice?.noteOn(ch: 0, noteNumber: LMIDI.noteNumber(noteName: noteButton.titleLabel!.text!)!, velocity: 64)      //ノートオンを送信する
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [self] Timer in                                         //1秒後にノートオフを送信する
            midiDevice?.noteOff(ch: 0, noteNumber: LMIDI.noteNumber(noteName: noteButton.titleLabel!.text!)!, velocity: 64)
        }
    }
    
    @IBAction func previewButton(_ sender: Any) {
        midiDevice?.notePreview(ch: 0)
    }
    
    //MARK: - notification
    /*==========================================================================
     
     =========================================================================*/
    @objc func messageReceived(_ notification: Notification) {
        let packets = notification.userInfo![LMIDI.receivedPacketKey] as! Data
        
        print(notification.userInfo as Any)             //userInfoの中に入っているものを表示する
        print(String(format: "Message Name: %@(%@)",    //メッセージの名称、パケットの中身を表示する
                     LMIDI.messageName(of: packets)!,
                     String(packets)))
    }
    
    /*==========================================================================
     
     =========================================================================*/
    @objc func controlChangeReceived(_ notification: Notification) {
        let packets = notification.userInfo![LMIDI.receivedPacketKey] as! Data
        
        print(String(format: "Control Change Type: %@(%02X)",   //コントロールチェンジ名・番号を表示する
                     LMIDI.controlChangeName(CC: packets[1])!,
                     packets[1]))
    }
}

//MARK: -
/*==============================================================================
 
 =============================================================================*/
extension String {
    init(_ data: Data) {
        self.init()
        
        for d in data {
            append(String(format: "%02X ", d))
        }
        if data.count > 0 {
            removeLast()    //最後のスペースを削除する
        }
    }
}
