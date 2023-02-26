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
    
    /// Will return the current photos access permission
    public static func getCurrentPhotosPermissionStatus() -> PHAuthorizationStatus {
        return PHPhotoLibrary.authorizationStatus()
    }
    
    /// Will request the photos request permission
    public static func requestPhotosVideosAccessPermission(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
        PHPhotoLibrary.requestAuthorization(completion)
    }
    
    /// Will stop a running data request
    public static func cancelDataRequest(by requestId: PHImageRequestID) {
        PHAssetResourceManager.default().cancelDataRequest(requestId)
    }
    
    /// Will stop a running image request
    public static func cancelImageRequest(by requestId: PHImageRequestID) {
        PHImageManager.default().cancelImageRequest(requestId)
    }
    
    /// Will load a specific image with an optional quality reduction for faster load
    public static func loadImage(from asset: PHAsset,
                                 withTargetReduction factor: CGFloat = 1.0,
                                 completion: @escaping (UIImage?) -> Void)
    -> PHAssetResourceDataRequestID? {
        // Request the photo data
        let targetSize = CGSize(width: CGFloat(asset.pixelWidth) * factor,
                                height: CGFloat(asset.pixelHeight) * factor)
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        let reqId = PHImageManager.default().requestImage(for: asset,
                                                          targetSize: targetSize,
                                                          contentMode: .aspectFit,
                                                          options: options) {  image, hashh in
            completion(image)
        }
        return reqId
    }
    
    
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
    
    /// Will return all the videos which answer the predicate (title) and return them by creation date
    public static func fetchAssets(fromAlbumIdentifier localIdentifier: String,
                                   limitTo count: Int,
                                   andFilterBy types: [PHAssetMediaType]) -> PHFetchResult<PHAsset>? {
        
        // take the album and filter
        guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [localIdentifier], options: nil).firstObject else {return nil}
        
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = count
        options.predicate = buildTypesPredicate(types: types)
        let assets = PHAsset.fetchAssets(in: album, options: options)
        return assets
    }
    
    /// Will return all the videos which answer the predicate (title) and return them by creation date
    public static func fetchAssets(andFilterBy types: [PHAssetMediaType]) -> [PHAsset] {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.predicate = buildTypesPredicate(types: types)
        var assets = [PHAsset]()
        let result = PHAsset.fetchAssets(with: options)
        result.enumerateObjects { (asset, _, _) in
            assets.append(asset)
        }
        return assets
    }
    
    /// Will return all the assets made before a certain asset
    public static func fetchAssets(from albumLocalIdentifier: String,
                                   olderThan asset: PHAsset,
                                   assetCount: Int,
                                   andFilterBy types: [PHAssetMediaType]) -> PHFetchResult<PHAsset>? {
        guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier],
                                                                  options: nil).firstObject else {return nil}
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        if let creationDate = asset.creationDate {
            let datePredicate = NSPredicate(format: "creationDate < %@",  creationDate as NSDate)
            options.predicate = datePredicate
        }
        options.fetchLimit = assetCount
        let assets = PHAsset.fetchAssets(in: album, options: options)
        return assets
    }
    
    /// Will return all the assets made after a certain asset
    public static func fetchAssets(from albumLocalIdentifier: String,
                                   takenAfter asset: PHAsset,
                                   assetCount: Int) -> PHFetchResult<PHAsset>? {
        guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier],
                                                                  options: nil).firstObject else {return nil}
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        options.predicate = NSPredicate(format: "creationDate > %@", asset.creationDate! as NSDate)
        options.fetchLimit = assetCount

        let assets = PHAsset.fetchAssets(in: album, options: options)
        return assets
    }
    
    
    private static func buildTypesPredicate(types: [PHAssetMediaType]) -> NSCompoundPredicate {
        var predicate = NSCompoundPredicate()
        types.enumerated().forEach { (idx, value) in
            let newCondition = NSCompoundPredicate(format: "mediaType = %d", value.rawValue)
            if types.count > 1, idx > 0 {
                predicate = NSCompoundPredicate(orPredicateWithSubpredicates: [predicate, newCondition])
            } else {
                predicate = newCondition
            }
        }
        return predicate
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
                                                 options: PHAssetResourceRequestOptions,
                                                 dataReceivedHandler: @escaping (Data) -> Void,
                                                 completion: @escaping (Error?) -> Void) -> PHAssetResourceDataRequestID? {
        guard let resource = PHAssetResource.assetResources(for: asset).first else {
            return nil
        }
        let reqId = PHAssetResourceManager.default().requestData(for: resource,
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
