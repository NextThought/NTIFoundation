//
//  LayoutDescription.swift
//  NTIFoundation
//
//  Created by Bryan Hoke on 4/19/16.
//  Copyright © 2016 NextThought. All rights reserved.
//

import UIKit

/// Data used for creating layout info.
public struct LayoutDescription {
	
	public var size = CGSize.zero
	
	public var contentOffset = CGPoint.zero
	
	public var contentInset = UIEdgeInsets.zero
	
	public var bounds = CGRect.zero
	
	public var sections: [SectionDescription] = []
	
	public var globalSection: SectionDescription?
	
}

/// Data used for creating a layout section.
public struct SectionDescription {
	
	public init(metrics: SectionMetrics) {
		self.metrics = metrics
	}
	
	public var sectionIndex = NSNotFound
	
	public var numberOfItems = 0
	
	public var metrics: SectionMetrics
	
	public var sizingInfo: CollectionViewLayoutMeasuring?
	
	public var supplementaryItemsByKind: [String: [SupplementaryItem]] = [:]
	
	public var placeholder: LayoutPlaceholder?
	
	public var draggedItemIndex: Int?
	
	public var phantomCellIndex: Int?
	
	public var phantomCellSize = CGSize.zero
	
}
