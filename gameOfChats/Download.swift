//
//  Download.swift
//  QuickChat
//
//  Created by Aidan Aden on 12/5/17.
//  Copyright © 2017 Aidan Aden. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

// MARK: Video Functions

func downloadVideo(videoUrl: String, result: @escaping (_ isReadyToPlay: Bool, _ videoFileName: String) -> Void) {
    
    let videoURL = URL(string: videoUrl)
    let videoFileName = videoUrl.components(separatedBy: "/").last!
    
    if fileExistsAtPath(path: videoFileName) {
        
        print("AIDAN: video exists in device, no need to download")
        result(true, videoFileName)
        
    } else {
        
        let downloadQueue = DispatchQueue(label: "downloadVideoQueue")
        
        downloadQueue.async {
            
            let data = NSData(contentsOf: videoURL!)
            
            if data != nil {
                
                var docUrl = getDocumentsDirectory()
                docUrl = docUrl.appendingPathComponent(videoFileName, isDirectory: false)
                
                data!.write(to: docUrl, atomically: true)
                print("AIDAN: Downloaded video")
                
                DispatchQueue.main.async {
                    
                    result(true, videoFileName)
                }
            } else {
                
//                ProgressHUD.showError("Unable to obtain video from database!")
            }
        }
    }
}

func thumbnailImageForFileUrl(videoFileURL: URL) -> UIImage? {
    
    let asset = AVAsset(url: videoFileURL)
    let assetGenerator = AVAssetImageGenerator(asset: asset)
    
    do {
        let thumbnailCGImage = try assetGenerator.copyCGImage(at: CMTime(value: 1, timescale: 60), actualTime: nil) // tries to obtain image of first frame of video
        
        return UIImage(cgImage: thumbnailCGImage)
        
    } catch let err {
        
        print(err)
    }
    
    return nil
}


func videoThumbNail(video: NSURL) -> UIImage {
    
    let asset = AVURLAsset(url: video as URL, options: nil)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, 1000)
    var actualTime = kCMTimeZero
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    } catch let error as NSError {
        
        print(error.localizedDescription)
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}



// MARK: Helper Functions

func fileInDocumentsDirectory(fileName: String) -> String {
    
    let fileUrl = getDocumentsDirectory().appendingPathComponent(fileName)
    
    return fileUrl.path
}

func getDocumentsDirectory() -> URL {
    
    let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last
    
    return documentURL!
}

func fileExistsAtPath(path: String) -> Bool {
    
    var doesExist = false
    
    let filePath = fileInDocumentsDirectory(fileName: path)
    let fileManager = FileManager.default
    
    if fileManager.fileExists(atPath: filePath) {
        doesExist = true
    }
    
    return doesExist
}

















