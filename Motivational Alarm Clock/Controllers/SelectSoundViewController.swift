//
//  SelectSoundViewController.swift
//  Motivational Alarm Clock
//
//  Created by talal ahmad on 13/01/2021.
//  Copyright © 2021 Alek Matthiessen. All rights reserved.
//

import UIKit
import Foundation
import AudioToolbox
import AVFoundation
class SelectSoundViewController: UIViewController ,AVAudioPlayerDelegate{
    var allSounds:[Sounds] = [Sounds(soundName: "newtrack2", title: "A Heart Less heavy", image: "giveup", category: "Motivation"),Sounds(soundName: "tickle", title: "yes yes you can", image: "youcan", category: "Self Help"),Sounds(soundName: "bell", title: "A Mighty Heart", image: "giveup", category: "Motivation")]
    var filteredSounds:[Sounds] = []
    var selectedSound:Sounds?
    var soundsCategories = ["Motivation","Self Help","Fitness","faith"]
    var selectedCategory = "Motivation"
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var collectionView: UICollectionView!
    var mediaLabel: String!
    var mediaID: String!
    var image:String!
    var soundtitle:String!
    var audioPlayer: AVAudioPlayer?
    override func viewDidLoad() {
        super.viewDidLoad()
        var error: NSError?
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
        } catch let error1 as NSError{
            error = error1
            print("could not set session. err:\(error!.localizedDescription)")
        }
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error1 as NSError{
            error = error1
            print("could not active session. err:\(error!.localizedDescription)")
        }
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        collectionView.dataSource = self
        collectionView.delegate = self
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        let bounds = UIScreen.main.bounds
        let width = bounds.width
        layout.itemSize = CGSize(width: 80, height: 90)
        collectionView.collectionViewLayout = layout
        
        tagSelection(tag: selectedCategory)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    performSegue(withIdentifier: Id.soundUnwindIdentifier, sender: self)
        
    }
    func tagSelection(tag:String){
        filteredSounds = allSounds.filter({$0.category == tag})
        if filteredSounds.count > 0 {
            selectedSound = filteredSounds[0]
        }
        self.collectionView.reloadData()
    }
    //AVAudioPlayerDelegate protocol
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    func stopSound() {
        if audioPlayer!.isPlaying {
            audioPlayer!.stop()
        }
        
    }
    func playSound(_ soundName: String) {
        
        //vibrate phone first
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        //set vibrate callback
        AudioServicesAddSystemSoundCompletion(SystemSoundID(kSystemSoundID_Vibrate),nil,
            nil,
            { (_:SystemSoundID, _:UnsafeMutableRawPointer?) -> Void in
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            },
            nil)
        let url = URL(fileURLWithPath: Bundle.main.path(forResource: soundName, ofType: "mp3")!)
        
        var error: NSError?
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
        } catch let error1 as NSError {
            error = error1
            audioPlayer = nil
        }
        
        if let err = error {
            print("audioPlayer error \(err.localizedDescription)")
            return
        } else {
            audioPlayer!.delegate = self
            audioPlayer!.prepareToPlay()
        }
        
        //negative number means loop infinity
        audioPlayer!.numberOfLoops = -1
        audioPlayer!.play()
    }
    
   @objc func playPauseAction(sender : UIButton){
    sender.setImage(UIImage(), for: .normal)
    sender.setImage(UIImage(), for: .selected)
        stopSound()
    }
}
extension SelectSoundViewController:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == tagsCollectionView {
            return soundsCategories.count
        }else{
            return filteredSounds.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.alpha = 1.0
        if collectionView == self.tagsCollectionView{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            
            let tag = soundsCategories[indexPath.row]
            cell.titleButton.setTitle(tag, for: .normal)
            cell.titleButton.setTitle(tag, for: .selected)
            cell.titleButton.layer.cornerRadius = 10
            if selectedCategory == tag {
                cell.titleButton.alpha = 1.0
            }else{
                cell.titleButton.alpha = 0.5
            }
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SoundPickCollectionViewCell", for: indexPath) as! SoundPickCollectionViewCell
            let sound = filteredSounds[indexPath.row]
            cell.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            cell.playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .selected)
            cell.coverImageView.image = UIImage(named: sound.image)
            if let selected = selectedSound {
                if sound == selected{
                    cell.playPauseButton.isHidden = false
                    cell.selectCheckMarkButton.isHidden = false
                    playSound(sound.soundName)
                }else{
                    cell.playPauseButton.isHidden = true
                    cell.selectCheckMarkButton.isHidden = true
                }
            }
            cell.playPauseButton.tag = indexPath.row
            cell.playPauseButton.addTarget(self,
                                           action: #selector(self.playPauseAction(sender:)),
                    for: .touchUpInside)

            cell.topMainView.layer.cornerRadius = 10
            cell.coverImageView.layer.cornerRadius = 10
            cell.mainView.layer.cornerRadius = 10
            return cell
        }

    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.alpha = 0.0
        if collectionView == tagsCollectionView {
            let generator = UIImpactFeedbackGenerator(style: .heavy)
            generator.impactOccurred()
            selectedCategory = soundsCategories[indexPath.row]
            tagSelection(tag: selectedCategory)
            tagsCollectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.centeredHorizontally, animated: true)
            self.tagsCollectionView.reloadData()
        }else{
            let sound = filteredSounds[indexPath.row]
            selectedSound = sound
            playSound(selectedSound!.soundName)
            self.collectionView.reloadData()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == tagsCollectionView {
            return CGSize(width: 90, height: 30)
        }else{
            
            let bounds = UIScreen.main.bounds
            let width = bounds.width
            return CGSize(width: width/2, height: 250)
        }

    }
    
    
}



struct Sounds:Equatable {
    var soundName:String
    var title:String
    var image:String
    var category:String
    static func == (lhs: Sounds, rhs: Sounds) -> Bool {
            return lhs.category == rhs.category && lhs.title == rhs.title && lhs.image == rhs.image  && lhs.soundName == rhs.soundName
        }
}
