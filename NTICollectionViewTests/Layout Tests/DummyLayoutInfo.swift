//
//  DummyLayoutInfo.swift
//  NTICollectionView
//
//  Created by Bryan Hoke on 2/18/16.
//  Copyright © 2016 NextThought. All rights reserved.
//

import UIKit

class DummyLayoutInfo: NSObject, LayoutInfo {

	var collectionViewSize = CGSizeZero
	
	var width: CGFloat = 0
	
	var height: CGFloat = 0
	
	var heightAvailableForPlaceholders: CGFloat = 0
	
	var contentOffset = CGPointZero
	
	var contentInset = UIEdgeInsetsZero
	
	var bounds = CGRectZero
	
	var layoutMeasure: CollectionViewLayoutMeasuring?
	
	var isEditing = false
	
	var numberOfSections = 0
	
	var hasGlobalSection = false
	
	var sections: [LayoutSection] = []
	
	func mutateSection(at index: Int, using mutator: (inout LayoutSection) -> Void) {
		
	}
	
	func mutateItem(at indexPath: NSIndexPath, using mutator: (inout LayoutItem) -> Void) {
		
	}
	
	func enumerateSections(block: (sectionIndex: Int, inout sectionInfo: LayoutSection, stop: inout Bool) -> Void) {
		
	}
	
	func sectionAtIndex(sectionIndex: Int) -> LayoutSection? {
		return sections[sectionIndex]
	}
	
	func setSection(section: LayoutSection, at sectionIndex: Int) {
		sections[sectionIndex] = section
	}
	
	func add(section: LayoutSection, sectionIndex: Int) {
		sections.insert(section, atIndex: sectionIndex)
	}
	
	func newPlaceholderStartingAtSectionIndex(sectionIndex: Int) -> LayoutPlaceholder {
		return BasicLayoutPlaceholder(sectionIndexes: NSIndexSet())
	}
	
	func invalidate() {
		
	}
	
	func finalizeLayout() {
		
	}
	
	func setSize(size: CGSize, forItemAt indexPath: NSIndexPath, invalidationContext: UICollectionViewLayoutInvalidationContext?) {
		
	}
	
	func setSize(size: CGSize, forElementOfKind kind: String, at indexPath: NSIndexPath, invalidationContext: UICollectionViewLayoutInvalidationContext?) {
		
	}
	
	func invalidateMetricsForItemAt(indexPath: NSIndexPath, invalidationContext: UICollectionViewLayoutInvalidationContext?) {
		
	}
	
	func invalidateMetricsForElementOfKind(kind: String, at indexPath: NSIndexPath, invalidationContext: UICollectionViewLayoutInvalidationContext?) {
		
	}
	
	func layoutAttributesForCell(at indexPath: NSIndexPath) -> CollectionViewLayoutAttributes? {
		return nil
	}
	
	func layoutAttributesForDecorationViewOfKind(kind: String, at indexPath: NSIndexPath) -> CollectionViewLayoutAttributes? {
		return nil
	}
	
	func layoutAttributesForSupplementaryElementOfKind(kind: String, at indexPath: NSIndexPath) -> CollectionViewLayoutAttributes? {
		return nil
	}
	
	func prepareForLayout() {
		
	}
	
	func updateSpecialItemsWithContentOffset(contentOffset: CGPoint, invalidationContext: UICollectionViewLayoutInvalidationContext?) {
		
	}
	
}

