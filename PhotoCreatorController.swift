//
//  PhotoCreatorController.swift
//  urcal
//
//  Created by Kilian Hiestermann on 09.05.17.
//  Copyright © 2017 Kilian Hiestermann. All rights reserved.
//

import UIKit
import Photos

class PhotoCreatorController: UICollectionViewController, UICollectionViewDelegateFlowLayout  {

    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage = UIImage()
    var header: PickedPhotoHeader?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView?.backgroundColor = UIColor.white
        
        let layout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
        setupNavigationButtons()
        
        collectionView?.register(PhotoSelectorCell.self, forCellWithReuseIdentifier: "cellId")
        
        collectionView?.register(PickedPhotoHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "headerId")
        
        fetchPhotos()
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    // setting up header
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "headerId", for: indexPath) as! PickedPhotoHeader
        
        self.header = header
        
        header.imageView.image = selectedImage
        
            if let index = self.images.index(of: selectedImage) {
                let selectedAsset = self.assets[index]
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 600, height: 600)
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .aspectFit, options: nil, resultHandler: { (image,  info) in
                    header.imageView.image = image
                })
            }

        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let width = self.view.frame.width
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(1, 0, 0, 0)
    }
    
    // setting up navigation bar
    
    fileprivate func setupNavigationButtons(){
        navigationController?.navigationBar.tintColor = .black
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    
    // setting up cells
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! PhotoSelectorCell
        
        
        cell.imageView.image = images[indexPath.item]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = (view.frame.width - 3)/4
        
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
 
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedImage =  images[indexPath.item]
        self.collectionView?.reloadData()
    }
    
    
    //getting Photos
    
    fileprivate func assetsFetchOptions() -> PHFetchOptions{
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.fetchLimit = 40
        let sortDescription = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchOptions.sortDescriptors = [sortDescription]
        
        return fetchOptions
    }
    
    fileprivate func fetchPhotos() {
        
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = self.assetsFetchOptions()
            
            let allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            
            allPhotos.enumerateObjects({ (asset, count, stop) in
                print(asset)
                let targetSize = CGSize(width: 200 , height: 200)
                let imageManager = PHImageManager.default()
                
                //handle options
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options, resultHandler: { (image, info) in
                    
                    if let image = image{
                        self.images.append(image)
                        self.assets.append(asset)
                    }
                    
                    if count == allPhotos.count  - 1 {
                        
                        DispatchQueue.main.async {
                            self.collectionView?.reloadData()
                        }
    
                        self.selectedImage = self.images[0]
                    }
                })
            })
        }
    }
  
    // handle navigation methods
    
    func handleNext() {
         let sharePhotoController = SharePhotoController()
        sharePhotoController.selectedImage = header?.imageView.image
        navigationController?.pushViewController(sharePhotoController, animated: true)
        
    }
     
    func handleCancel() {
        
        dismiss(animated: true, completion: nil)
    
    }

}
