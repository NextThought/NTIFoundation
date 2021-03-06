//
//  NTIEditableFrame.h
//  NextThoughtApp
//
//  Created by Jason Madden on 2011/08/22.
//  Copyright (c) 2011 NextThought. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OmniUI/OUITextView.h"
#import <OmniAppKit/OATextAttachmentCell.h>

@class NTIEditableFrame;
@protocol NTIEditableFrameTextAttachmentCellDelegate <NSObject>
@optional
-(BOOL)editableFrame: (NTIEditableFrame*)editableFrame
	  attachmentCell: (OATextAttachmentCell*)attachmentCell
   wasTouchedAtPoint: (CGPoint)point;

-(BOOL)editableFrame: (NTIEditableFrame*)editableFrame
	  attachmentCell: (OATextAttachmentCell*)attachmentCell
 wasSelectedWithRect: (CGRect)rect;

-(void)editableFrame: (NTIEditableFrame*)editableFrame
	 attachmentCells: (NSArray*)cells
selectionModeChangedWithRects: (NSArray*)rects;

@end

/**
 * Extend the OUITextView with some helpful messages (particularily around attachment handling)
 */
@interface NTIEditableFrame : OUITextView

+(NSAttributedString*)attributedStringMutatedForDisplay: (NSAttributedString*)str;
+(CGFloat)heightForAttributedString: (NSAttributedString*)str width: (CGFloat)width;

@property (nonatomic, weak) id<NTIEditableFrameTextAttachmentCellDelegate> attachmentDelegate;
@property (nonatomic, assign) BOOL shouldSelectAttachmentCells;

-(void)replaceRange: (UITextRange*)range withObject: (id)object;
-(OATextAttachmentCell*)attachmentCellForPoint: (CGPoint)point fromView: (UIView*)view;

#pragma mark keyboard handling
- (void)nti_adjustForKeyboardHidingWithPreferedFinalBottomContentInset:(CGFloat)bottomInset animated:(BOOL)animated;
- (void)nti_scrollRectToVisibleAboveLastKnownKeyboard:(CGRect)rect animated:(BOOL)animated completion:(void (^)(BOOL))completion;
@end

