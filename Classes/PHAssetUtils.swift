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
    
    /**
     Loads the image data for the specified asset at the target size.

     - Parameters:
        - asset: The PHAsset object for the image to be loaded.
        - targetSize: The desired size of the image to be loaded.
        - completion: A closure to be called when the image loading completes, with the resulting UIImage object or nil if the loading failed.

     - Returns: An identifier for the PHAssetResourceDataRequest operation, or nil if the loading failed.
    */
    public static func loadImage(for asset: PHAsset,
                                 by targetSize: CGSize,
                                 completion: @escaping (UIImage?) -> Void)
    -> PHAssetResourceDataRequestID? {
        // Request the photo data
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
    
    /**
     Fetches a collection of assets from the user's Photos library that were taken before the specified asset.

     - Parameters:
       - asset: The asset that serves as an ending point for the fetch. Only assets captured before this asset will be returned.
       - albumLocalIdentifier: The local identifier of the album to fetch assets from. If nil, fetches assets from all albums.
       - assetCount: The maximum number of assets to fetch. If nil, fetches all assets.
       - filterTypes: An optional array of media types to filter the fetched assets by.
     - Returns: A `PHFetchResult` instance that represents the fetched assets, or nil if an error occurred.
    */
    public static func fetchAssetsTakenBefore(asset: PHAsset,
                                              fromAlbumLocalIdentifier albumLocalIdentifier: String? = nil,
                                              limitTo assetCount: Int? = nil,
                                              andFilterBy filterTypes: [PHAssetMediaType]? = nil) -> PHFetchResult<PHAsset>? {
        
        let options = buildStandardFetchOptions(sortByDate: true,
                                                ascendingSort: false,
                                                fetchCount: assetCount,
                                                filterTypes: filterTypes)
        if let creationDate = asset.creationDate {
            let datePredicate = NSPredicate(format: "creationDate < %@",  creationDate as NSDate)
            if let typesPredicate = options.predicate {
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typesPredicate, datePredicate])
                options.predicate = predicate
            } else {
                options.predicate = datePredicate
            }
        }
        if let albumLocalIdentifier = albumLocalIdentifier {
            guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier],
                                                                      options: nil).firstObject else {return nil}
            var assets = PHAsset.fetchAssets(in: album, options: options)
            return assets
        }
        return PHAsset.fetchAssets(with: options)
    }
    
    
    /**
     Fetches a collection of assets from the user's Photos library that were taken after the specified asset.

     - Parameters:
       - asset: The asset that serves as a starting point for the fetch. Only assets captured after this asset will be returned.
       - albumLocalIdentifier: The local identifier of the album to fetch assets from. If nil, fetches assets from all albums.
       - assetCount: The maximum number of assets to fetch. If nil, fetches all assets.
       - filterTypes: An optional array of media types to filter the fetched assets by.
     - Returns: A `PHFetchResult` instance that represents the fetched assets, or nil if an error occurred.
    */
    public static func fetchAssetsTakenAfter(asset: PHAsset,
                                             fromAlbumLocalIdentifier albumLocalIdentifier: String? = nil,
                                             limitTo assetCount: Int? = nil,
                                             andFilterBy filterTypes: [PHAssetMediaType]? = nil) -> PHFetchResult<PHAsset>? {
        let options = buildStandardFetchOptions(sortByDate: true,
                                                ascendingSort: true,
                                                fetchCount: assetCount,
                                                filterTypes: filterTypes)
        if let creationDate = asset.creationDate {
            let datePredicate = NSPredicate(format: "creationDate > %@",  creationDate as NSDate)
            if let typesPredicate = options.predicate {
                let predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [typesPredicate, datePredicate])
                options.predicate = predicate
            } else {
                options.predicate = datePredicate
            }
        }
        if let albumLocalIdentifier = albumLocalIdentifier {
            guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier],
                                                                      options: nil).firstObject else {return nil}
            return PHAsset.fetchAssets(in: album, options: options)
        }
        return PHAsset.fetchAssets(with: options)
    }
    
    
    /**
     Fetches a collection of the most recent assets from the user's Photos library.

     - Parameters:
       - albumLocalIdentifier: The local identifier of the album to fetch assets from. If nil, fetches assets from all albums.
       - assetCount: The maximum number of assets to fetch. If nil, fetches all assets.
       - ascendingSort: A boolean flag that determines whether to sort the fetched assets by ascending or descending date order.
       - filterTypes: An optional array of media types to filter the fetched assets by.
     - Returns: A `PHFetchResult` instance that represents the fetched assets, or nil if an error occurred.
    */
    public static func fetchMostRecentAssets(fromAlbumLocalIdentifier albumLocalIdentifier: String? = nil,
                                             limitTo assetCount: Int? = nil,
                                             sortByAscending ascendingSort: Bool = false,
                                             andFilterBy filterTypes: [PHAssetMediaType]? = nil) -> PHFetchResult<PHAsset>? {
        let options = buildStandardFetchOptions(sortByDate: true,
                                                ascendingSort: ascendingSort,
                                                fetchCount: assetCount,
                                                filterTypes: filterTypes)
        if let albumLocalIdentifier = albumLocalIdentifier {
            guard let album = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [albumLocalIdentifier],
                                                                      options: nil).firstObject else {return nil}
            return PHAsset.fetchAssets(in: album, options: options)
        }
        return PHAsset.fetchAssets(with: options)
    }
    
    /**
     Builds a `PHFetchOptions` instance with standard settings.

     - Parameters:
       - sortByDate: A Boolean value that indicates whether to sort the fetched assets by creation date.
       - fetchCount: The maximum number of assets to fetch. If nil, fetches all assets.
       - filterTypes: An optional array of media types to filter the fetched assets by.
     - Returns: A `PHFetchOptions` instance with the specified settings.
    */
    private static func buildStandardFetchOptions(sortByDate: Bool,
                                                  ascendingSort: Bool?,
                                                  fetchCount: Int? = nil,
                                                  filterTypes: [PHAssetMediaType]? = nil)
    -> PHFetchOptions {
        let options = PHFetchOptions()
        if sortByDate {
            var _ascendingSort = false
            if let ascendingSort = ascendingSort {
                _ascendingSort = ascendingSort
            }
            options.sortDescriptors = [NSSortDescriptor(key: "creationDate",
                                                        ascending: _ascendingSort)]
        }
        if let filterTypes = filterTypes {
            options.predicate = buildTypesPredicate(types: filterTypes)
        }
        if let fetchCount = fetchCount {
            options.fetchLimit = fetchCount
        }
        return options
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
    
    
    /**
     Saves a video at the given URL to the user's photo album.
     
     - Parameters:
     - videoURL: The URL of the video file to save.
     - completion: A closure to be called once the save operation has completed. The closure takes a single parameter: a boolean indicating whether the operation was successful.
     
     - Note: This function requires the `Photos` framework to be imported.
     
     - Warning: This function will request permission to access the user's photo library if permission has not already been granted.
     */
    public static func saveVideoToAlbum(videoURL: URL,
                                        completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false)
                return
            }
            
            PHPhotoLibrary.shared().performChanges({
                guard let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL) else {
                    completion(false)
                    return
                }
                request.creationDate = Date()
            }) { success, error in
                if success {
                    print("Video saved to album")
                } else if let error = error {
                    print("Error saving video to album: \(error.localizedDescription)")
                } else {
                    print("Unknown error saving video to album")
                }
                
                completion(success)
            }
        }
    }
    
    
    /**
     * Retrieves a `PHAssetCollection` with the given name.
     *
     * - Parameters:
     *   - albumName: The name of the asset collection to retrieve.
     * - Returns: The first `PHAssetCollection` with the given name, or `nil` if no matching collection is found.
     */
    public static func getAlbum(named albumName: String) -> PHAssetCollection? {
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "title = %@", albumName)
        let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .any, options: fetchOptions)
        return collections.firstObject
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
    public static func stopLoadChunks(from requestId: PHAssetResourceDataRequestID) {
        PHAssetResourceManager.default().cancelDataRequest(requestId)
    }
    
    
    public static func requestAccessToPhotos(_ completion: @escaping (PHAuthorizationStatus) -> Void) {
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
