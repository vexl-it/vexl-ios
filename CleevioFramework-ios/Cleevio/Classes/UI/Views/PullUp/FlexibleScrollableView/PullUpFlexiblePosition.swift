//
//  PullUpFlexiblePosition.swift
//  CleevioUI
//
//  Created by Daniel Fernandez on 2/17/21.
//

import SwiftUI

public enum PositionType {
    case max
    case middle
    case min
}

public struct PullUpFlexiblePosition {
    var offset: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        let positionHeight = screenHeight * screenPercentage
        return screenHeight - positionHeight
    }

    let screenPercentage: CGFloat
    let type: PositionType

    public init(screenPercentage: CGFloat, type: PositionType) {
        self.screenPercentage = screenPercentage
        self.type = type
    }

    public static func maxPosition(from positions: [PullUpFlexiblePosition]) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        guard let maxPosition = positions.first(where: { $0.type == .max }) else {
            fatalError("You don't have a maximun position...")
        }

        return maxPosition
    }

    public static func minPosition(from positions: [PullUpFlexiblePosition]) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        guard let minPosition = positions.first(where: { $0.type == .min }) else {
            fatalError("You don't have a minimum position...")
        }

        return minPosition
    }

    public static func middlePosition(from positions: [PullUpFlexiblePosition]) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        if positions.count == 2 {
            return minPosition(from: positions)
        } else {
            let middlePositions = positions.filter({ $0.type == .middle })

            if middlePositions.isEmpty {
                fatalError("There is no middle position, please check your types...")
            } else if middlePositions.count == 1 {
                return positions.first(where: { $0.type == .middle })!
            } else {
                return middlePositions.min(by: { $0.screenPercentage > $1.screenPercentage })!
            }
        }
    }

    public static func closestPosition(from positions: [PullUpFlexiblePosition],
                                       currentPosition: PullUpFlexiblePosition) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        var closestPosition = maxPosition(from: positions)
        var difference = closestPosition.screenPercentage - currentPosition.screenPercentage

        for position in positions {
            let diff = position.screenPercentage - currentPosition.screenPercentage
            guard diff > 0 else { continue }
            if diff < difference {
                difference = diff
                closestPosition = position
            }
        }

        return closestPosition
    }

    public static func abovePosition(from positions: [PullUpFlexiblePosition],
                                     currentPosition: PullUpFlexiblePosition) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        guard currentPosition.screenPercentage != (positions.map { $0.screenPercentage }.max()) else {
            return currentPosition
        }

        var abovePosition = maxPosition(from: positions)
        var difference = abovePosition.screenPercentage - currentPosition.screenPercentage

        for position in positions {
            let diff = position.screenPercentage - currentPosition.screenPercentage
            guard diff > 0 else { continue }
            if diff < difference {
                difference = diff
                abovePosition = position
            }
        }

        return abovePosition
    }

    public static func belowPosition(from positions: [PullUpFlexiblePosition],
                                     currentPosition: PullUpFlexiblePosition) -> PullUpFlexiblePosition {
        guard positions.count >= 2 else {
            fatalError("You have to give at least 2 positions...")
        }

        guard currentPosition.screenPercentage != (positions.map { $0.screenPercentage }.min()) else {
            return currentPosition
        }

        var belowPosition = minPosition(from: positions)
        var difference = currentPosition.screenPercentage - belowPosition.screenPercentage

        for position in positions {
            let diff = currentPosition.screenPercentage - position.screenPercentage
            guard diff > 0 else { continue }
            if diff < difference {
                difference = diff
                belowPosition = position
            }
        }

        return belowPosition
    }
}
