//
//  DataSourceSectionInfo.swift
//  NTICollectionView
//
//  Created by Bryan Hoke on 2/18/16.
//  Copyright © 2016 NextThought. All rights reserved.
//

import UIKit

public protocol DataSourceSectionInfo {
	
	var placeholder: AnyObject? { get set }
	
	var supplementaryItemsByKind: [String: [SupplementaryItem]] { get set }
	
	mutating func add(_ supplementaryItem: SupplementaryItem)
	
}

extension DataSourceSectionInfo {
	
	public var supplementaryItems: [SupplementaryItem] {
		return supplementaryItemsByKind.values.reduce([], +)
	}
	
	public func supplementaryItemsOfKind(_ kind: String) -> [SupplementaryItem] {
		return supplementaryItemsByKind[kind] ?? []
	}
	
	public mutating func add(_ supplementaryItem: SupplementaryItem) {
		let kind = supplementaryItem.elementKind
		var items = supplementaryItemsOfKind(kind)
		items.append(supplementaryItem)
		supplementaryItemsByKind[kind] = items
	}
	
}
