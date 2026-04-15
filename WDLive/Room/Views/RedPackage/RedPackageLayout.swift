import UIKit

/// Custom layout that centers items and provides paging/snapping.
/// Scale transforms are intentionally NOT applied here to avoid flicker;
/// the collection view delegate handles them via scrollViewDidScroll.
final class RedPackageLayout: UICollectionViewFlowLayout {
    let spacing: CGFloat = 20
  
    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        scrollDirection = .horizontal
        minimumLineSpacing = spacing
        let itemW = cv.bounds.width * 0.7
        let itemH = cv.bounds.height
        itemSize = CGSize(width: itemW, height: itemH)
        let inset = (cv.bounds.width - itemW) / 2
        sectionInset = UIEdgeInsets(top: 0, left: inset, bottom: 0, right: inset)
        
    }

    /// Only invalidate when the view SIZE changes (not on every scroll offset tick).
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let cv = collectionView else { return false }
        
        return newBounds.size != cv.bounds.size
    }

    /// Snap to the nearest item center when a scroll gesture ends.
    override func targetContentOffset(
        forProposedContentOffset proposedContentOffset: CGPoint,
        withScrollingVelocity velocity: CGPoint
    ) -> CGPoint {
        guard let cv = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let proposedCenterX = proposedContentOffset.x + cv.bounds.width / 2
        // Search rect wider than the visible area to find off-screen candidates
        let searchRect = CGRect(
            x: proposedContentOffset.x - itemSize.width,
            y: 0,
            width: cv.bounds.width + itemSize.width * 2,
            height: cv.bounds.height
        )
        guard let allAttrs = super.layoutAttributesForElements(in: searchRect) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        let cellAttrs = allAttrs.filter { $0.representedElementCategory == .cell }
        guard let best = cellAttrs.min(by: { abs($0.center.x - proposedCenterX) < abs($1.center.x - proposedCenterX) }) else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        return CGPoint(x: best.center.x - cv.bounds.width / 2, y: proposedContentOffset.y)
    }
}
