//
//  PHAssetUtils.swift
//  TelegraphWebServer
//
//  Created by Oz Shabbat on 25/01/2023.
//

import Foundation
import Photos
import AVKit

public class PHAssetUtils {
    
    /// Will return a suitable asset from an asset's local identifier
    public static func asset(from localIdentifier: String) -> PHAsset? {
        let options = PHFetchOptions()
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: options)
        if assets.count == 0 {
            return nil // file not found. Serving failed
        }
        return assets.firstObject
    }
    
    /// Will return the biggest video on the device
    public static func getBiggestVideo() -> PHAsset {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        var longestVideoDuration = 0
        var biggestPH = PHAsset()
        let videos = PHAsset.fetchAssets(with: options)
        for i in 0...videos.count - 1 {
            let currDuration = Int(videos[i].duration)
            if currDuration > longestVideoDuration {
                longestVideoDuration = currDuration
                biggestPH = videos[i]
            }
        }
        
        return biggestPH
    }
    
    /// Will return the biggest photo on the device
    public static func getBiggestPhoto() -> PHAsset {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        var biggestPhoto = 0
        var biggestPH = PHAsset()
        let images = PHAsset.fetchAssets(with: options)
        for i in 0...images.count - 1 {
            let currSize = Int(images[i].getFileSize())
            if currSize > biggestPhoto {
                biggestPhoto = currSize
                biggestPH = images[i]
            }
        }
        
        return biggestPH
    }
    
    /// Provide a local identifier to get the suitable PHAsset
    public static func localIdentifierToPh(identifier: String) -> PHAsset? {
        let options = PHFetchOptions()
        let videos = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: options)
        return videos.firstObject
    }
    
    
    /// Will return an AVAsset from a PHAsset
    public static func phToAV(ph: PHAsset) -> AVAsset? {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.isNetworkAccessAllowed = true
        
        let sema = CompletableSemaphore<AVAsset>()
        PHImageManager.default().requestAVAsset(forVideo: ph, options: options) { (avAsset, audioMix, info) in
            sema.complete(result: avAsset)
        }
        let avAsset = sema.wait()
        return avAsset
    }
    
    /// Will return the data of the current asset, by chunks
    @discardableResult
    public static func exportAssetToDataByChunks(asset: PHAsset,
                                                 dataReceivedHandler: @escaping (Data) -> Void,
                                                 completion: @escaping (Error?) -> Void) -> PHAssetResourceDataRequestID? {
        let options = PHAssetResourceRequestOptions()
        options.isNetworkAccessAllowed = true
        let manager = PHAssetResourceManager.default()
        guard let resource = PHAssetResource.assetResources(for: asset).first else {
            return nil
        }
        let reqId = manager.requestData(for: resource,
                                        options: options,
                                        dataReceivedHandler: dataReceivedHandler,
                                        completionHandler: { error in
            completion(error)
        })
        return reqId
    }
    
    /// Will stop a running chunks loading
    static func stopLoadChunks(from requestId: PHAssetResourceDataRequestID) {
        PHAssetResourceManager.default().cancelDataRequest(requestId)
    }
    
    
    static func requestAccessToPhotos(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization(completion)
        }
    }
}


extension PHAsset {
    
    /// Will return the primary asset resource of the asset by the media type
    public var primaryResource: PHAssetResource? {
        let types: Set<PHAssetResourceType>
        
        switch mediaType {
        case .video:
            types = [.video, .fullSizeVideo]
        case .image:
            types = [.photo, .fullSizePhoto]
        case .audio:
            types = [.audio]
        case .unknown:
            types = []
        @unknown default:
            types = []
        }
        
        let resources = PHAssetResource.assetResources(for: self)
        let resource = resources.first { types.contains($0.type)}
        
        return resource ?? resources.first
    }
    
    /// Will return the asset's name
    public var originalFilename: String {
        guard let result = primaryResource else {
            return "file"
        }
        
        return result.originalFilename
    }
    
    /// Will return the file size of the asset
    public func getFileSize() -> Int {
        let resources = PHAssetResource.assetResources(for: self)
        guard let resource = resources.first,
              let intSize = resource.value(forKey: "fileSize") as? Int else {
            return 0
        }
        return intSize
        
    }

}
