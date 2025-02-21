//
//  RiveFallbackFontDescriptorTests.swift
//  RiveRuntime
//
//  Created by David Skuza on 8/9/24.
//  Copyright © 2024 Rive. All rights reserved.
//

import XCTest
@testable import RiveRuntime

class RiveFontTests: XCTestCase {
    override func setUp() {
        RiveFont.fallbackFonts = []
    }

    func testSystemFallbackDefaults() {
        var defaults = RiveFont.fallbackFonts.compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(defaults.first?.design, .default)
        XCTAssertEqual(defaults.first?.weight, .regular)

        // Set and unset the system fallbacks to make sure the default is correctly set
        RiveFont.fallbackFonts = [
            RiveFallbackFontDescriptor(design: .monospaced, weight: .bold)
        ]

        RiveFont.fallbackFonts = []

        defaults = RiveFont.fallbackFonts.compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(defaults.first?.design, .default)
        XCTAssertEqual(defaults.first?.weight, .regular)
    }

    func testSystemFallbackCallbackDefaults() {
        let style = RiveFontStyle(weight: .regular)
        let defaults = RiveFont.fallbackFontsCallback(style).compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(defaults.first?.design, .default)
        XCTAssertEqual(defaults.first?.weight, .regular)
    }

    func testSystemFallbackCallbackUsesFallbackFontsByDefault() {
        RiveFont.fallbackFonts = [RiveFallbackFontDescriptor(weight: .heavy)]
        let style = RiveFontStyle(weight: .regular)
        let defaults = RiveFont.fallbackFontsCallback(style).compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(defaults.first?.weight, .heavy)
    }

    func testSystemFallbackCallbackOverridesFallbackFonts() {
        RiveFont.fallbackFonts = [
            RiveFallbackFontDescriptor(weight: .heavy)
        ]

        let style = RiveFontStyle(weight: .regular)
        var fonts = RiveFont.fallbackFontsCallback(style).compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(fonts.first?.weight, .heavy)

        RiveFont.fallbackFontsCallback = { _ in
            return [RiveFallbackFontDescriptor(weight: .thin)]
        }

        fonts = RiveFont.fallbackFontsCallback(style).compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(fonts.first?.weight, .thin)
    }

    func testSystemFallbackFontsOverridesFallbackCallback() {
        RiveFont.fallbackFontsCallback = { _ in
            return [RiveFallbackFontDescriptor(weight: .thin)]
        }

        RiveFont.fallbackFonts = [
            RiveFallbackFontDescriptor(weight: .regular)
        ]

        let style = RiveFontStyle(weight: .regular)
        var fonts = RiveFont.fallbackFontsCallback(style).compactMap { $0 as? RiveFallbackFontDescriptor }
        XCTAssertEqual(fonts.first?.weight, .regular)
    }

    func testSystemDesignsReturnFonts() {
        let defaultDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .regular)
        let defaultFont = defaultDescriptor.fallbackFont

        let roundedDescriptor = RiveFallbackFontDescriptor(design: .rounded, weight: .regular)
        let roundedFont = roundedDescriptor.fallbackFont

        let monospacedDescriptor = RiveFallbackFontDescriptor(design: .monospaced, weight: .regular)
        let monospacedFont = monospacedDescriptor.fallbackFont

        let serifDescriptor = RiveFallbackFontDescriptor(design: .serif, weight: .regular)
        let serifFont = serifDescriptor.fallbackFont

        // Assert that each descriptor returns a unique font name (i.e for each system design)
        let fontNames = Set([
            defaultFont.fontName,
            roundedFont.fontName,
            monospacedFont.fontName,
            serifFont.fontName]
        )
        XCTAssertEqual(fontNames.count, 4)
    }

    func testWeightsReturnFonts() {
        func usage(from font: UIFont) -> RiveFallbackFontUIUsage {
            let value = font.fontDescriptor.fontAttributes[.init(rawValue: "NSCTFontUIUsageAttribute")] as! String
            return RiveFallbackFontUIUsage(rawValue: value)!
        }
        
        let ultraLightDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .ultraLight)
        let ultraLightFont = ultraLightDescriptor.fallbackFont
        XCTAssertEqual(usage(from: ultraLightFont), .ultraLight)

        let thinDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .thin)
        let thinFont = thinDescriptor.fallbackFont
        XCTAssertEqual(usage(from: thinFont), .thin)

        let lightDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .light)
        let lightFont = lightDescriptor.fallbackFont
        XCTAssertEqual(usage(from: lightFont), .light)

        let regularDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .regular)
        let regularFont = regularDescriptor.fallbackFont
        XCTAssertEqual(usage(from: regularFont), .regular)

        let mediumDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .medium)
        let mediumFont = mediumDescriptor.fallbackFont
        XCTAssertEqual(usage(from: mediumFont), .medium)

        let semiboldDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .semibold)
        let semiboldFont = semiboldDescriptor.fallbackFont
        XCTAssertEqual(usage(from: semiboldFont), .semibold)

        let boldDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .bold)
        let boldFont = boldDescriptor.fallbackFont
        XCTAssertEqual(usage(from: boldFont), .bold)

        let heavyDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .heavy)
        let heavyFont = heavyDescriptor.fallbackFont
        XCTAssertEqual(usage(from: heavyFont), .heavy)

        let blackDescriptor = RiveFallbackFontDescriptor(design: .default, weight: .black)
        let blackFont = blackDescriptor.fallbackFont
        XCTAssertEqual(usage(from: blackFont), .black)

        // Assert that each descriptor returns a unique font name (i.e for each weight)
        let fontNames = Set([
            ultraLightFont.fontName,
            thinFont.fontName,
            lightFont.fontName,
            regularFont.fontName,
            mediumFont.fontName,
            semiboldFont.fontName,
            boldFont.fontName,
            heavyFont.fontName,
            blackFont.fontName
        ])
        XCTAssertEqual(fontNames.count, 9)
    }

    func testWidthReturnsFonts() {
        // For all widths, there should still be a weight trait added, regardless of OS
        func width(from font: UIFont) -> CGFloat? {
            let traits = font.fontDescriptor.object(forKey: .traits) as! [UIFontDescriptor.TraitKey: Any]
            let width = traits[.width] as! CGFloat
            return width
        }

        let condensedDescriptor = RiveFallbackFontDescriptor(width: .condensed)
        let condensedFont = condensedDescriptor.fallbackFont
        // iOS 16+ will use a system width, < iOS 16 uses a default value, both < 0
        let condensedWidth = width(from: condensedFont)
        XCTAssertNotNil(condensedWidth)
        XCTAssertLessThan(condensedWidth!, 0)

        let compressedDescriptor = RiveFallbackFontDescriptor(width: .compressed)
        let compressedFont = condensedDescriptor.fallbackFont
        // iOS 16+ will use a system width, < iOS 16 uses a default value, both < 0
        let compressedWidth = width(from: compressedFont)
        XCTAssertNotNil(compressedWidth)
        XCTAssertLessThan(compressedWidth!, 0)

        let regularDescriptor = RiveFallbackFontDescriptor(width: .standard)
        let regularFont = regularDescriptor.fallbackFont
        // iOS 16+ will use a system width, < iOS 16 uses a default value, both == 0
        let regularWidth = width(from: regularFont)
        XCTAssertNotNil(regularWidth)
        XCTAssertEqual(regularWidth!, 0)

        let expandedDescriptor = RiveFallbackFontDescriptor(width: .expanded)
        let expandedFont = condensedDescriptor.fallbackFont
        // iOS 16+ will use a system width, < iOS 16 uses a default value, both >
        let expandedWidth = width(from: expandedFont)
        XCTAssertNotNil(expandedWidth)
        XCTAssertLessThan(expandedWidth!, 0)
    }

    func testRiveFontStyleWeightFromRawWeight() {
        // "Normal" weights
        var style = RiveFontStyle(rawWeight: 100)
        XCTAssertEqual(style.weight, .thin)

        style = RiveFontStyle(rawWeight: 200)
        XCTAssertEqual(style.weight, .ultraLight)

        style = RiveFontStyle(rawWeight: 300)
        XCTAssertEqual(style.weight, .light)

        style = RiveFontStyle(rawWeight: 400)
        XCTAssertEqual(style.weight, .regular)

        style = RiveFontStyle(rawWeight: 500)
        XCTAssertEqual(style.weight, .medium)

        style = RiveFontStyle(rawWeight: 600)
        XCTAssertEqual(style.weight, .semibold)

        style = RiveFontStyle(rawWeight: 700)
        XCTAssertEqual(style.weight, .bold)

        style = RiveFontStyle(rawWeight: 800)
        XCTAssertEqual(style.weight, .heavy)

        style = RiveFontStyle(rawWeight: 900)
        XCTAssertEqual(style.weight, .black)

        style = RiveFontStyle(rawWeight: -100)
        XCTAssertEqual(style.weight, .thin)

        // Outliers
        style = RiveFontStyle(rawWeight: 0)
        XCTAssertEqual(style.weight, .thin)

        style = RiveFontStyle(rawWeight: 1000)
        XCTAssertEqual(style.weight, .black)

        // Rounding
        style = RiveFontStyle(rawWeight: 149)
        XCTAssertEqual(style.weight, .thin)

        style = RiveFontStyle(rawWeight: 151)
        XCTAssertEqual(style.weight, .ultraLight)
    }
}
