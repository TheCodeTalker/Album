//
//  ZLBalancedFlowLayout.swift
//  ZLBalancedFlowLayoutDemo
//
//  Created by Zhixuan Lai on 12/20/14.
//  Copyright (c) 2014 Zhixuan Lai. All rights reserved.
//

import UIKit

protocol SetPartitionAfterInsideUpload : class {
     func setPartitionAfterInsideUpload()
}

open class ZLBalancedFlowLayout: UICollectionViewFlowLayout {
    /// The ideal row height of items in the grid
    open var rowHeight: CGFloat = 100 {
        didSet {
            invalidateLayout()
        }
    }
    weak var setPartitionDelegate:SetPartitionAfterInsideUpload?
    
    var isNested = false
    
    
    /// The option to enforce the ideal row height by changing the aspect ratio of the item if necessary.
    open var enforcesRowHeight: Bool = false {
        didSet {
            invalidateLayout()
        }
    }
    
    var frameArray = [CGRect]()
    
    typealias partitionTypeLayout = Array<Array<Array<String>>>
    var localPartition  = Array<Array<Array<String>>>()
    
    fileprivate var headerFrames = [CGRect](), footerFrames = [CGRect]()
    fileprivate var itemFrames = [[CGRect]](), itemOriginYs = [[CGFloat]]()
    fileprivate var contentSize = CGSize.zero
    let defaults = UserDefaults.standard
    var numberOfRows = 0
    
    // TODO: shouldInvalidateLayoutForBoundsChange
    
    open override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if let local = defaults.object(forKey: "partition") as? partitionTypeLayout{
            //containSameElements(local, localPartition)
            if compareElement(local, self.localPartition){
                return false
            }else{
                return true
            }
        }
        return true
        }

    
    func compareElement(_ array1:partitionTypeLayout,_ array2 : partitionTypeLayout) -> Bool {
                guard array1.count == array2.count else {
                    return false
        }
        
        //return array1 == array2
        
        for (index,element) in array1.enumerated(){
            if element.count == array2[index].count{
                var d2Array = array2[index]
                
                for(index1,element1) in element.enumerated(){
                    var d1Array = d2Array[index1]
                    if element1.count != d2Array[index1].count{
                     return false
                    }
                        for (index2,element2) in element1.enumerated(){
                            
                            if element2 != d1Array[index2]{
                                return false
                            }
                            
                        }
                        
                    
                }
            }
            else{
                return false
            }
            
        }
        
        return true
        
        
    }
    
    
    func weightsForItemsInSection(count:Int,withInitialIndex index:Int) -> [Float] {
        
        var  width  = [Float]()
        
        if let collectionView = self.collectionView {
        let maxWidth = Float(scrollDirection == .vertical ? contentSize.width : contentSize.height)
        for i in (index ..< count) {
            let itemSize = self.sizeForItemAtIndexPath(IndexPath(item: i, section: 0)),
            ratio = self.scrollDirection == .vertical ?
                itemSize.width/itemSize.height :
                itemSize.height/itemSize.width
            width.append(min(Float(ratio*self.rowHeight), Float(maxWidth)))
            
        }
        }
        return width
        
    }
    
    // MARK: - UICollectionViewLayout
    override open func prepare() {
        resetItemFrames()
        contentSize = CGSize.zero
        
        if let collectionView = self.collectionView {
            
            guard  let  totalItems = self.collectionView?.numberOfItems(inSection: 0) else{ return }
            
            if let isViewStory = defaults.object(forKey: "isViewStory") as? Bool{
                if isViewStory{
                    if (self.collectionView?.numberOfItems(inSection: 0))! >  0{
                        if let local = defaults.object(forKey: "partition") as? partitionTypeLayout{
                            localPartition = local
                            
                        }
                        defaults.set(false, forKey: "isViewStory")
                    }
                    
                }else{
                    if let delete = defaults.object(forKey: "deletedAllItems") as? Bool, delete == false , self.localPartition.count <= 0{
                        
                        
                        
                        var  width  = [Float]()
                        let maxWidth = Float(scrollDirection == .vertical ? contentSize.width : contentSize.height)
                        for i in (0..<collectionView.numberOfItems(inSection: 0)) {
                            let itemSize = self.sizeForItemAtIndexPath(IndexPath(item: i, section: 0)),
                            ratio = self.scrollDirection == .vertical ?
                                itemSize.width/itemSize.height :
                                itemSize.height/itemSize.width
                            width.append(min(Float(ratio*self.rowHeight), Float(maxWidth)))
                            
                        }
                        
                        // parition widths
                      
                           var local = partition(width, max: Float(maxWidth))
                            UserDefaults.standard.set(local, forKey: "partition")
                  
                       // if let local = defaults.object(forKey: "partition") as? partitionTypeLayout{
                            localPartition = local
                        //}

                        
                        
    
                    }else{
                        
                       if let addedMorePhotos  = defaults.object(forKey: "addedMorePhotos") as? Int , addedMorePhotos > 0{
                            if let local = defaults.object(forKey: "partition") as? partitionTypeLayout{
                                localPartition = local
                            }
                        
                        
                            let newItems = defaults.object(forKey: "addedMorePhotos") as! Int
                            
                            let numberOfNewItems = totalItems - newItems
                        
                        
                        var  width  = [Float]()
                        let maxWidth = Float(scrollDirection == .vertical ? contentSize.width : contentSize.height)
                        for i in (numberOfNewItems ..< totalItems) {
                            let itemSize = self.sizeForItemAtIndexPath(IndexPath(item: i, section: 0)),
                            ratio = self.scrollDirection == .vertical ?
                                itemSize.width/itemSize.height :
                                itemSize.height/itemSize.width
                            width.append(min(Float(ratio*self.rowHeight), Float(maxWidth)))
                            
                        }
                        
                        // parition widths
                        
                        var local = partition(width, max: Float(maxWidth))
                        
                        let initialCount = localPartition.count
                        self.localPartition.append(contentsOf: local)
                        
                        for i in initialCount ..< (initialCount + local.count) {
                            var destPartArray = self.localPartition[i]
                            for j in 0 ..< destPartArray.count{
                                var colArray = destPartArray[j]
                                for k in 0 ..< colArray.count{
                                    colArray[k] = "\(i)-\(j)-\(k)"
                                }
                                destPartArray[j] = colArray
                                
                            }
                            self.localPartition[i] = destPartArray
                        }

                        UserDefaults.standard.set(0, forKey: "addedMorePhotos")
                        UserDefaults.standard.set(self.localPartition, forKey: "partition")
                       
                     //   localPartition = local
                    
                        }else{
                            if let local = defaults.object(forKey: "partition") as? partitionTypeLayout{
                                localPartition = local
                                
                            }
                        }
                        
                    }
                    
                  
                        

                }
            }
            
            self.setPartitionDelegate?.setPartitionAfterInsideUpload()
            
            
            
            contentSize = scrollDirection == .vertical ?
                CGSize(width: collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right, height: 0) :
                CGSize(width: 0, height: collectionView.bounds.size.height - collectionView.contentInset.top - collectionView.contentInset.bottom)
            
            
            var sectionOffset = CGPoint.init()
            var sectionSize = CGSize.zero
            var numberItems  = collectionView.numberOfItems(inSection: 0)
            var section  = collectionView.numberOfSections - 1

            
            for section in (0..<collectionView.numberOfSections) {
                let headerFrame = self.collectionView(collectionView, frameForHeader: true, inSection: section, updateContentSize: &contentSize)
                headerFrames.append(headerFrame)
                
               // var headerSize = self.collectionView(self.collectionView!, frameForHeader: true, inSection: section, updateContentSize: &contentSize)
                sectionOffset = CGPoint(x: 0, y: headerFrame.height)//CGPointMake(0, contentSize.height + headerSize.height);
                
                
               let (frames1, originYs1) = self.collectionLayoutElement(collectionView, framesForItemsInSection: section, numberOf: numberItems, sectionOff: sectionOffset, updateContentSize: &sectionSize)
              //let (frames, originYs) = self.collectionView(collectionView, framesForItemsInSection: section, updateContentSize: &contentSize)
                itemFrames.append(frames1)
                itemOriginYs.append(originYs1)
            let footerFrame =  self.collectionView(collectionView, frameForHeader: false, inSection: section, updateContentSize: &contentSize)
                
                let myfooterFrame = CGRect(x: 0, y: headerFrame.height + sectionSize.height, width: collectionView.bounds.width, height: footerFrame.height)
                footerFrames.append(myfooterFrame)
                contentSize = CGSize(width: sectionSize.width, height: (contentSize.height +  sectionSize.height))
            }
            
           
            
            //CGPoint sectionOffset
           
        }
    }
    
    
    
    
    func totalItemSizeForSection(count:Int,preferredRow preferredRowSize:CGFloat,withInitailIndex index:Int) -> CGFloat {
        var totalItemSize = CGFloat(0)
        for i in index ..< count{
            let preferredSize =  self.sizeForItemAtIndexPath(IndexPath(item: i, section: 0))
            totalItemSize += (preferredSize.width / preferredSize.height) * preferredRowSize
            
        }
        
        return totalItemSize

        
    }
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        
        if let collectionView = self.collectionView {
            // can be further optimized
            for section in (0..<collectionView.numberOfSections) {
                let sectionIndexPath = IndexPath(item: 0, section: section)
                if let headerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: sectionIndexPath), headerAttributes.frame.size != CGSize.zero && headerAttributes.frame.intersects(rect) {
                    layoutAttributes.append(headerAttributes)
                }
                if let footerAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionFooter, at: sectionIndexPath), footerAttributes.frame.size != CGSize.zero && footerAttributes.frame.intersects(rect) {
                    layoutAttributes.append(footerAttributes)
                }
                var minY = CGFloat(0), maxY = CGFloat(0)
                if (scrollDirection == .vertical) {
                    minY = rect.minY-rect.height
                    maxY = rect.maxY
                } else {
                    minY = rect.minX-rect.width
                    maxY = rect.maxX
                }
                let lowerIndex = binarySearch(itemOriginYs[section], value: minY)
                let upperIndex = binarySearch(itemOriginYs[section], value: maxY)
                
//                var numberItems  = collectionView.numberOfItems(inSection: 0)
//                
//                for  i in 0 ..< numberItems {
//                let itemFrame = frameArray[i]
//                    if rect.intersects(itemFrame)
//                    {
//                    layoutAttributes.append(self.layoutAttributesForItem(at: IndexPath(item: i, section: section)))
//                    }
//                    
//                }
                for item in lowerIndex..<upperIndex {
                    layoutAttributes.append(self.layoutAttributesForItem(at: IndexPath(item: item, section: section)))
                }
                
                
            }
        }
        return layoutAttributes
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        attributes?.frame = itemFrames[indexPath.section][indexPath.row]
        return attributes
    }
    
    override open func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes! {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        
        switch (elementKind) {
        case UICollectionElementKindSectionHeader:
            attributes.frame = headerFrames[indexPath.section]
        case UICollectionElementKindSectionFooter:
            attributes.frame = footerFrames[indexPath.section]
        default:
            return nil
        }
        // If there is no header or footer, we need to return nil to prevent a crash from UICollectionView private methods.
        if(attributes.frame.isEmpty) {
            return nil;
        }
        
        return attributes
    }
    
    override open var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    // MARK: - UICollectionViewLayout Helpers
    fileprivate func collectionView(_ collectionView:UICollectionView, frameForHeader isForHeader:Bool, inSection section:Int, updateContentSize contentSize:inout CGSize) -> CGRect {
        var size = referenceSizeForHeader(isForHeader, inSection: section), frame = CGRect.zero
        if (scrollDirection == .vertical) {
            frame = CGRect(x: 0, y: contentSize.height, width: collectionView.bounds.width, height: size.height);
            contentSize = CGSize(width: contentSize.width, height: contentSize.height+size.height)
        } else {
            frame = CGRect(x: contentSize.width, y: 0, width: size.width, height: collectionView.bounds.height);
            contentSize = CGSize(width: contentSize.width+size.width, height: contentSize.height)
        }
        return frame
    }
    
    
    fileprivate func collectionLayoutElement(_ collectionView:UICollectionView, framesForItemsInSection section: Int,numberOf numberOfRows: Int,sectionOff sectionOffset: CGPoint, updateContentSize contentSize:inout CGSize) -> ([CGRect], [CGFloat])  {
        
        var i = 0
        var count = 0
        var itemCount = 0
        
        var framesArray = [String]()
        var rowHeight = CGFloat(0)
        frameArray.removeAll()
        
        var offset = CGPoint(x: sectionOffset.x + self.sectionInset.left, y: sectionOffset.y + self.sectionInset.top)
        var previousItemSize = CGFloat.init()
        var contentMaxValueInScrollDirection = CGFloat.init()
        var actualSize = CGSize.zero
        var actualWidth = CGFloat.greatestFiniteMagnitude
        var actualHeight = CGFloat.leastNormalMagnitude
        var frameForEachRow = [String]()
        var framesInSection = [CGRect](), originYsInSection = [CGFloat]()
        
        
        for (_,indexArray) in localPartition.enumerated(){
            var summedRatios = CGFloat(0)
            var rectForRow = CGRect.zero
            rectForRow.origin.x = offset.x
            rectForRow.origin.y = offset.y
            var n = indexArray.count
            
            for j  in 0 ..< n {
                var preferredWidth = CGFloat.leastNormalMagnitude
                var preferredHeight = CGFloat.leastNormalMagnitude
                var valueToAdd = CGFloat(0.0)
                if (indexArray[j].count == 1){
                    let preferredSize = self.sizeForItemAtIndexPath(IndexPath(item: count, section: section))
                    
                    preferredWidth = preferredSize.width
                    preferredHeight = preferredSize.height
                    
                    valueToAdd = preferredWidth/preferredHeight
                    count  = count + 1
                }else{
                    var ratio = CGFloat(0.0)
                    for k in 0 ..< indexArray[j].count {
                        let preferredSize = self.sizeForItemAtIndexPath(IndexPath(item: count, section: section))
                        
                        ratio += preferredSize.height/preferredSize.width
                        count = count + 1
                    }
                    valueToAdd = 1/ratio
                    
                }
                
                summedRatios +=  valueToAdd
                
            }
            
            var rowSize = (self.viewPortAvailableSize().width - self.sectionInset.left - self.sectionInset.right) -  CGFloat(indexArray.count - 1) * self.minimumInteritemSpacing
            
            rowHeight = CGFloat(roundf(Float(rowSize) / Float(summedRatios)))
            
            
            
            rectForRow.size.height = CGFloat(rowHeight)
            rectForRow.size.width = self.viewPortAvailableSize().width
            
            for (index,insideArray) in indexArray .enumerated(){
                if insideArray.count == 1{
                    
                    let preferredSize = self.sizeForItemAtIndexPath(IndexPath(item: itemCount, section: section))
                    var width = (rowSize/summedRatios) * (preferredSize.width/preferredSize.height)
                    actualSize = CGSize(width: width, height: rowHeight)
                    var frame = CGRect(x: offset.x, y: offset.y, width: actualSize.width, height: actualSize.height)
                    frameArray.append(NSValue(cgRect: frame) as CGRect)
                    framesArray.append(NSStringFromCGRect(frame))
                    //need to write some code
                    framesInSection.append(frame)
                    previousItemSize  = actualSize.height
                    contentMaxValueInScrollDirection = frame.maxY
                    itemCount += 1
                    offset.x += actualSize.width + self.minimumInteritemSpacing;
                    originYsInSection.append(offset.y)
                    
                }else{
                    var yOffset = offset.y
                    var actualRowHeight = rowHeight - (CGFloat(insideArray.count - 1) * self.minimumLineSpacing)
                    var preferredWidth = CGFloat.init()
                    var summedRatioHeight = CGFloat.init()
                    
                    var dItemCount = itemCount
                    for (_,inside) in insideArray.enumerated(){
                        let preferredSize = self.sizeForItemAtIndexPath(IndexPath(item: dItemCount, section: section))
                        summedRatioHeight += preferredSize.height/preferredSize.width
                        dItemCount += 1
                    }
                    
                    preferredWidth = (rowSize/summedRatios) * (1/summedRatioHeight)
                    
                    for (index,inside) in insideArray.enumerated(){
                        let preferredSize = self.sizeForItemAtIndexPath(IndexPath(item: itemCount, section: section))
                        actualWidth = preferredWidth
                        actualHeight = (actualRowHeight/summedRatioHeight) * (preferredSize.height/preferredSize.width)
                        var frame = CGRect(x: offset.x, y: offset.y, width: actualWidth, height: actualHeight)
                        frameArray.append(NSValue(cgRect: frame) as CGRect)
                        framesArray.append(NSStringFromCGRect(frame))
                        
                        
                        framesInSection.append(frame)
                        
                        offset.y += actualHeight + self.minimumInteritemSpacing
                        previousItemSize = actualSize.height
                        contentMaxValueInScrollDirection = frame.maxY
                        itemCount += 1
                        originYsInSection.append(offset.y)
                        
                        
                    }
                    offset.y = yOffset
                    offset.x += actualWidth + self.minimumInteritemSpacing
                    
                    
                }
                        }
            i += 1
            var strictRectForEachRow = NSStringFromCGRect(rectForRow)
            
            frameForEachRow.append(strictRectForEachRow)
            
            if (indexArray.count > 0) {
                offset = CGPoint(x: self.sectionInset.left, y: offset.y+rowHeight+8.0)
                isNested = false
            }
            
        }
        
        UserDefaults.standard.set(framesArray, forKey: "Frames")
        UserDefaults.standard.set(frameForEachRow, forKey: "FramesForEachRow")
        
        contentSize = CGSize(width: ((self.collectionView?.frame.width)! - (self.collectionView?.contentInset.left)! - (self.collectionView?.contentInset.right)!), height:(contentMaxValueInScrollDirection - sectionOffset.y) + self.sectionInset.bottom)
        
        return (framesInSection, originYsInSection)
        
    }
    
    
    
    
    
//    fileprivate func collectionView(_ collectionView:UICollectionView, framesForItemsInSection section:Int, updateContentSize contentSize:inout CGSize) -> ([CGRect], [CGFloat]) {
//        
//        var  width  = [Float]()
//        let maxWidth = Float(scrollDirection == .vertical ? contentSize.width : contentSize.height)
//        for i in (0..<collectionView.numberOfItems(inSection: section)) {
//            let itemSize = self.sizeForItemAtIndexPath(IndexPath(item: i, section: section)),
//            ratio = self.scrollDirection == .vertical ?
//                itemSize.width/itemSize.height :
//                itemSize.height/itemSize.width
//            width.append(min(Float(ratio*self.rowHeight), Float(maxWidth)))
//            
//        }
//        
//        defaults.removeObject(forKey: "partition")
//        defaults.synchronize()
//
//        
//        
//        // parition widths
//        let partitions = partition(width, max: Float(maxWidth))
//        
//        let minimumInteritemSpacing = minimumInteritemSpacingForSection(section),
//        minimumLineSpacing = minimumLineSpacingForSection(section),
//        inset = insetForSection(section)
//        var framesInSection = [CGRect](), originYsInSection = [CGFloat](),
//        origin = scrollDirection == .vertical ?
//            CGPoint(x: inset.left, y: contentSize.height+inset.top) :
//            CGPoint(x: contentSize.width+inset.left, y: inset.top)
//        
//        for row in partitions {
//            // contentWidth/summedWidth
//            let innerMargin = Float(CGFloat(row.count-1)*minimumInteritemSpacing),
//            outterMargin = scrollDirection == .vertical ?
//                Float(inset.left+inset.right) :
//                Float(inset.top+inset.bottom),
//            contentWidth = maxWidth - outterMargin - innerMargin,
//            widthRatio = CGFloat(contentWidth/row.reduce(0, +)),
//            heightRatio = enforcesRowHeight ? 1 : widthRatio
//            for width in row {
//                let size = scrollDirection == .vertical ?
//                    CGSize(width: CGFloat(width)*widthRatio, height: rowHeight*heightRatio) :
//                    CGSize(width: rowHeight*heightRatio, height: CGFloat(width)*widthRatio)
//                let frame = CGRect(origin: origin, size: size)
//                framesInSection.append(frame)
//                if scrollDirection == .vertical {
//                    origin = CGPoint(x: origin.x+frame.width+minimumInteritemSpacing, y: origin.y)
//                    originYsInSection.append(origin.y)
//                } else {
//                    origin = CGPoint(x: origin.x, y: origin.y+frame.height+minimumInteritemSpacing)
//                    originYsInSection.append(origin.x)
//                }
//            }
//            if scrollDirection == .vertical {
//                origin = CGPoint(x: inset.left, y: origin.y+framesInSection.last!.height+minimumLineSpacing)
//            } else {
//                origin = CGPoint(x: origin.x+framesInSection.last!.width+minimumLineSpacing, y: inset.top)
//            }
//        }
//        
//        if scrollDirection == .vertical {
//            contentSize = CGSize(width: contentSize.width, height: origin.y+inset.bottom)
//        } else {
//            contentSize = CGSize(width: origin.x+inset.right, height: contentSize.height)
//        }
//        
//        return (framesInSection, originYsInSection)
//    }
    
    
    
    func viewPortWidth() -> CGFloat {
        return (self.collectionView?.frame.width)! - self.collectionView!.contentInset.left - self.collectionView!.contentInset.right
    }
    
    func viewPortAvailableSize1() -> CGFloat {
        var availableSize = CGFloat(0)
        if (scrollDirection == .vertical)  {
            availableSize = self.viewPortWidth() - self.sectionInset.left - self.sectionInset.right
        }
        else {
            availableSize = self.viewPortHeight() - self.sectionInset.top - self.sectionInset.bottom
        }
        
        return availableSize;
    }
    
    
    func viewPortHeight() -> CGFloat{
        return (self.collectionView?.frame.height)! - self.collectionView!.contentInset.top - self.collectionView!.contentInset.bottom
    }

    
    
    func viewPortAvailableSize() -> CGSize{
        var availableSize = CGSize(width: 0, height: 0)
        var inset = insetForSection(0)
        var origin = scrollDirection == .vertical ?
            CGPoint(x: inset.left, y: contentSize.height+inset.top) :
            CGPoint(x: contentSize.width+inset.left, y: inset.top)
        if scrollDirection == .vertical {
            availableSize = CGSize(width: contentSize.width, height: origin.y+inset.bottom)
        } else {
            availableSize = CGSize(width: origin.x+inset.right, height: contentSize.height)
        }
        
        return availableSize
        
    }
    
    fileprivate func resetItemFrames() {
        headerFrames = [CGRect]()
        footerFrames = [CGRect]()
        itemFrames = [[CGRect]]()
        itemOriginYs = [[CGFloat]]()
    }
    
    // MARK: - Delegate Helpers
    fileprivate func referenceSizeForHeader(_ isForHeader: Bool, inSection section: Int) -> CGSize {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
            if isForHeader {
                if let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) {
                    return size
                }
            } else {
                if let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) {
                    return size
                }
            }
        }
        if isForHeader {
            return headerReferenceSize
        } else {
            return footerReferenceSize
        }
    }
    
    fileprivate func minimumLineSpacingForSection(_ section: Int) -> CGFloat {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let minimumLineSpacing = delegate.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) {
            return minimumLineSpacing
        }
        return minimumLineSpacing
    }
    
    fileprivate func minimumInteritemSpacingForSection(_ section: Int) -> CGFloat {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let minimumInteritemSpacing = delegate.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) {
            return minimumInteritemSpacing
        }
        return minimumInteritemSpacing
    }
    
    fileprivate func sizeForItemAtIndexPath(_ indexPath: IndexPath) -> CGSize {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt:indexPath) {
            return size
        }
        return itemSize
    }
    
    fileprivate func insetForSection(_ section: Int) -> UIEdgeInsets {
        if let collectionView = self.collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout, let inset = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: section){
            return inset
        }
        return sectionInset
    }
    
    // MARK: - ()
    fileprivate func binarySearch<T: Comparable>(_ array: Array<T>, value:T) -> Int{
        var imin=0, imax=array.count
        while imin<imax {
            let imid = imin+(imax-imin)/2
            
            if array[imid] < value {
                imin = imid+1
            } else {
                imax = imid
            }
        }
        return imin
    }
    
    // parition the widths in to rows using dynamic programming O(n^2)
    fileprivate func partition(_ values: [Float], max:Float) -> Array<Array<Array<String>>> {
        let numValues = values.count
        var array = Array<Array<Array<String>>>()
        if numValues == 0 {
            return []
        }
        
        var slacks = [[Float]](repeating: [Float](repeating: Float.infinity, count: numValues), count: numValues)
        for from in 0 ..< numValues {
            for to in from ..< numValues {
                let slack = to==from ? max-values[to] : slacks[from][to-1]-values[to]
                if slack >= 0 {
                    slacks[from][to] = slack
                } else {
                    break
                }
            }
        }
        
        // build up values of optimal solutions
        var opt = [Float](repeating: 0, count: numValues)
        opt[0] = pow(slacks[0][0], 2)
        for to in 1 ..< numValues {
            var minVal = Float.infinity
            for from in (0..<to){
                let slack = pow(slacks[from][to], 3)
                if slack > pow(max, 3) {
                    continue
                }
                let opp = (from==0 ? 0 : opt[from-1])
                minVal = min(minVal, slack+opp)
            }
            opt[to] = minVal
            
        }
        //            for var from=0; from<=to; from += 1 {
        //
        //        }
        
        // traceback the optimal solution
        var partitions = [[Float]]()
        findSolution(values, slacks: slacks, opt: opt, to: numValues-1, partitions: &partitions)
        
        // if let local : NSMutableArray = defaults.object(forKey: "partition") as? NSMutableArray{
        
    
          
            var insideArray = Array<Array<String>>()
            
            for (index1,value) in partitions.enumerated(){
                insideArray.removeAll()
                for (index,value) in value.enumerated(){
                    let placeHolder = "\(index1)-\(index)-\(0)"
                    
                    let element = [placeHolder]
                    // let element = NSArray(object: placeHolder)
                    insideArray.append(element)
                    //insideArray.add(element)
                }
                
                array.append(insideArray)
       
           // UserDefaults.standard.set(array, forKey: "partition")
        
            
        }
        
        
        
        
        
        return array
    }
    
    // traceback solution
    fileprivate func findSolution(_ values: [Float], slacks:[[Float]], opt: [Float], to: Int, partitions: inout [[Float]]) {
        if to<0 {
            partitions = partitions.reversed()
        } else {
            var minVal = Float.infinity, minIndex = 0
            for from in (0..<to).reversed(){
                
                if slacks[from][to] == Float.infinity {
                    continue
                }
                
                let curVal = pow(slacks[from][to], 3) + (from==0 ? 0 : opt[from-1])
                if minVal > curVal {
                    minVal = curVal
                    minIndex = from
                }
                
            }
            // for var from=to; from>=0; from -= 1 {
            //             }
            
            //  print("values\(values[minIndex...to])")
            
            
            
            
            
            
            partitions.append([Float](values[minIndex...to]))
            findSolution(values, slacks: slacks, opt: opt, to: minIndex-1, partitions: &partitions)
        }
    }
    
}
