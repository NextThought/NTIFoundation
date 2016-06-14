//
//  TableLayoutSectionBuilder.swift
//  NTIFoundation
//
//  Created by Bryan Hoke on 4/19/16.
//  Copyright © 2016 NextThought. All rights reserved.
//

import UIKit

public struct TableLayoutSectionBuilder: LayoutSectionBuilder {
	
	public func makeLayoutSection(using description: SectionDescription, in layoutBounds: LayoutAreaBounds) -> LayoutSection {
		var section = TableLayoutSection()
		
		var description = description
		description.metrics.resolveMissingValuesFromTheme()
		
		guard var metrics = description.metrics as? TableSectionMetricsProviding else {
			return section
		}
		
		let numberOfItems = description.numberOfItems
		let origin = layoutBounds.origin
		let width = layoutBounds.width
		let sectionIndex = description.sectionIndex
		let margins = metrics.padding
		
		section.sectionIndex = sectionIndex
		section.frame.origin = origin
		section.frame.size.width = layoutBounds.width
		
		section.applyValues(from: description.metrics)
		
		var positionBounds = layoutBounds
		
		// Layout headers
		if let headers = description.supplementaryItemsByKind[UICollectionElementKindSectionHeader] {
			let layoutItems = makeLayoutItems(for: headers, using: description, in: positionBounds)
			
			for layoutItem in layoutItems {
				positionBounds.origin.y += layoutItem.fixedHeight
				section.add(layoutItem)
			}
		}
		
		// Layout content area
		if var placeholder = description.placeholder where placeholder.startingSectionIndex == sectionIndex {
			// Layout placeholder
			placeholder.frame = CGRect(x: origin.x, y: origin.y, width: width, height: placeholder.height)
			
			if placeholder.hasEstimatedHeight, let sizing = description.sizingInfo {
				let measuredSize = sizing.measuredSizeForPlaceholder(placeholder)
				placeholder.height = measuredSize.height
				placeholder.frame.size.height = placeholder.height
				placeholder.hasEstimatedHeight = false
			}
			
			positionBounds.origin.y += placeholder.height
			section.placeholderInfo = placeholder
		}
		else if numberOfItems > 0 {
			// Layout items
			positionBounds.origin.y += margins.top
			
			var cellBounds = positionBounds
			cellBounds.origin.x += margins.left
			cellBounds.width -= margins.width
			
			let rows = TableRowStackBuilder().makeLayoutRows(using: description, in: cellBounds)
			
			for row in rows {
				positionBounds.origin.y += row.frame.height
				section.add(row)
			}
			
			positionBounds.origin.y += margins.bottom
		}
		
		// Layout footers
		if let footers = description.supplementaryItemsByKind[UICollectionElementKindSectionFooter] {
			let layoutItems = makeLayoutItems(for: footers, using: description, in: positionBounds)
			
			for layoutItem in layoutItems {
				positionBounds.origin.y += layoutItem.fixedHeight
				section.add(layoutItem)
			}
		}
		
		let sectionHeight = positionBounds.origin.y - origin.y
		section.frame.size.height = sectionHeight
		
		if sectionIndex == globalSectionIndex && metrics.backgroundColor != nil {
			var backgroundDecoration = BackgroundDecoration(elementKind: collectionElementKindGlobalHeaderBackground)
			backgroundDecoration.setContainerFrame(section.frame, invalidationContext: nil)
			backgroundDecoration.zIndex = defaultZIndex
			backgroundDecoration.isHidden = false
			backgroundDecoration.color = metrics.backgroundColor
			section.metrics.add(backgroundDecoration)
		}
		
		return section
	}
	
	private func makeLayoutItems(for supplementaryItems: [SupplementaryItem], using description: SectionDescription, in layoutBounds: LayoutAreaBounds) -> [TableLayoutSupplementaryItem] {
		return SupplementaryItemStackBuilder<TableLayoutSupplementaryItem>().makeLayoutItems(for: supplementaryItems, using: description, in: layoutBounds).map {
			var layoutItem = $0
			layoutItem.unpinnedY = layoutItem.frame.minY
			return layoutItem
		}
	}
	
}

public struct TableRowStackBuilder {
	
	typealias RowContext = (row: LayoutRow, position: CGPoint, rowHeight: CGFloat, itemHeight: CGFloat, columnIndex: Int)
	
	static let hairline = 1 / UIScreen.mainScreen().scale

	public func makeLayoutRows(using description: SectionDescription, in layoutBounds: LayoutAreaBounds) -> [LayoutRow] {
		var rows = [LayoutRow]()
		
		guard let metrics = description.metrics as? TableRowMetricsProviding else {
			return rows
		}
		
		let origin = layoutBounds.origin
		let width = layoutBounds.width
		
		let numberOfColumns = metrics.numberOfColumns
		let columnWidth = width / CGFloat(numberOfColumns)
		
		var position = origin
		var rowHeight: CGFloat = 0
		var itemHeight: CGFloat = 0
		var columnIndex = 0
		
		func makeRow() -> LayoutRow {
			var positionBounds = layoutBounds
			positionBounds.origin = position
			return self.makeRow(using: description, in: positionBounds)
		}
		
		var row = makeRow()
		
		func nextColumn() {
			if rowHeight < itemHeight {
				rowHeight = itemHeight
			}
			
			position.x += columnWidth
			
			columnIndex += 1
			
			row.frame.size.height = rowHeight
			
			guard columnIndex == numberOfColumns else {
				return
			}
			
			position.y += rowHeight
			rowHeight = 0
			columnIndex = 0
			
			position.x = origin.x
			
			if !row.items.isEmpty {
				decorate(&row, atIndex: rows.count, using: metrics)
				position.y = row.frame.maxY
				rows.append(row)
				
				row = makeRow()
			}
		}
		
		for itemIndex in 0..<description.numberOfItems {
			var item = makeItem(atIndex: itemIndex, using: description)
			
			if itemIndex == description.phantomCellIndex {
				itemHeight = description.phantomCellSize.height
				nextColumn()
			}
			
			itemHeight = item.frame.height
			item.frame.origin = position
			item.frame.size.width = columnWidth
			item.columnIndex = columnIndex
			
			if itemIndex == description.draggedItemIndex {
				row.add(item)
				continue
			}
			
			if item.hasEstimatedHeight, let sizing = description.sizingInfo {
				let measuredSize = sizing.measuredSizeForItem(item)
				itemHeight = measuredSize.height
				item.frame.size.height = itemHeight
				item.hasEstimatedHeight = false
			}
			
			row.add(item)
			
			nextColumn()
		}
		
		if !row.items.isEmpty {
			rows.append(row)
		}
		
		return rows
	}
	
	func makeRow(using description: SectionDescription, in layoutBounds: LayoutAreaBounds) -> LayoutRow {
		var row = LayoutRow()
		row.sectionIndex = description.sectionIndex
		
		let origin = layoutBounds.origin
		let size = CGSize(width: layoutBounds.width, height: 0)
		row.frame = CGRect(origin: origin, size: size)
		
		return row
	}
	
	func makeItem(atIndex itemIndex: Int, using description: SectionDescription) -> LayoutItem {
		var item = TableLayoutItem()
		
		item.itemIndex = itemIndex
		item.sectionIndex = description.sectionIndex
		
		if let metrics = description.metrics as? TableSectionMetrics {
			let rowHeight = metrics.rowHeight ?? metrics.estimatedRowHeight
			item.frame.size.height = rowHeight
			
			let isVariableRowHeight = metrics.rowHeight == nil
			item.hasEstimatedHeight = isVariableRowHeight
		}
		
		return item
	}
	
	func decorate(inout row: LayoutRow, atIndex index: Int, using metrics: TableRowMetricsProviding) {
		guard metrics.showsRowSeparator else {
			return
		}
		
		var separatorDecoration = HorizontalSeparatorDecoration(elementKind: collectionElementKindRowSeparator, position: .bottom)
		
		separatorDecoration.itemIndex = index
		separatorDecoration.sectionIndex = row.sectionIndex
		separatorDecoration.color = metrics.separatorColor
		separatorDecoration.zIndex = separatorZIndex
		
		let insets = metrics.separatorInsets
		separatorDecoration.leftMargin = insets.left
		separatorDecoration.rightMargin = insets.right
		
		separatorDecoration.setContainerFrame(row.frame, invalidationContext: nil)
		
		row.rowSeparatorDecoration = separatorDecoration
		row.frame.size.height += separatorDecoration.thickness
	}
	
}
