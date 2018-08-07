//
//  CigarReviewEnums.swift
//  CigarStack
//
//  Created by Darius Pasca on 28/07/2018.
//  Copyright © 2018 Darius Pasca. All rights reserved.
//

import Foundation


enum Appearance: Int {
    case veins = 0
    case notUniform = 1
    case uniform = 2
    case perfect = 3
    
    var displayName: String {
        switch self {
        case .veins:
            return NSLocalizedString("Veins", comment: "")
        case .notUniform:
            return  NSLocalizedString("Not Uniform", comment: "")
        case .uniform:
            return NSLocalizedString("Uniform", comment: "")
        case .perfect:
            return NSLocalizedString("Perfect", comment: "")
        }
    }
}

enum Texture: Int {
    case crumbly = 0
    case dry = 1
    case spongy = 2
    case perfect = 3
    
    var displayName: String {
        switch self {
        case .crumbly:
            return NSLocalizedString("Crumbly", comment: "")
        case .dry:
            return  NSLocalizedString("Dry", comment: "")
        case .spongy:
            return NSLocalizedString("Spongy", comment: "")
        case .perfect:
            return NSLocalizedString("Perfect", comment: "")
        }
    }
}

enum Draw: Int {
    case hard = 0
    case tight = 1
    case normal = 2
    case excellent = 3
    
    var displayName: String {
        switch self {
        case .hard:
            return NSLocalizedString("Hard", comment: "")
        case .tight:
            return  NSLocalizedString("Tight", comment: "")
        case .normal:
            return NSLocalizedString("Normal", comment: "")
        case .excellent:
            return NSLocalizedString("Excellent", comment: "")
        }
    }
}

enum Ash: Int {
    case britlte = 0
    case normal = 1
    case compact = 2
    case solid = 3
    
    var displayName: String {
        switch self {
        case .britlte:
            return NSLocalizedString("Britlte", comment: "")
        case .normal:
            return  NSLocalizedString("Normal", comment: "")
        case .compact:
            return NSLocalizedString("Compact", comment: "")
        case .solid:
            return NSLocalizedString("Solid", comment: "")
        }
    }
}

enum Strenght: Int {
    case light = 0
    case medium = 1
    case medfull = 2
    case full = 3
    
    var displayName: String {
        switch self {
        case .light:
            return NSLocalizedString("Light", comment: "")
        case .medium:
            return  NSLocalizedString("Medium", comment: "")
        case .medfull:
            return NSLocalizedString("Med-Full", comment: "")
        case .full:
            return NSLocalizedString("Full", comment: "")
        }
    }
}

enum Flavor: Int {
    case light = 0
    case medium = 1
    case medfull = 2
    case full = 3
    
    var displayName: String {
        switch self {
        case .light:
            return NSLocalizedString("Light", comment: "")
        case .medium:
            return  NSLocalizedString("Medium", comment: "")
        case .medfull:
            return NSLocalizedString("Med-Full", comment: "")
        case .full:
            return NSLocalizedString("Full", comment: "")
        }
    }
}
