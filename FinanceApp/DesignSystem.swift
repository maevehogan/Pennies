//
//  DesignSystem.swift
//  FinanceApp
//

import SwiftUI

// MARK: - Color Palette

extension Color {
    static let appBg         = Color(red: 0.04, green: 0.04, blue: 0.10)
    static let electricBlue  = Color(red: 0.04, green: 0.52, blue: 1.00)
    static let hotPink       = Color(red: 1.00, green: 0.18, blue: 0.33)
    static let neonPurple    = Color(red: 0.75, green: 0.35, blue: 0.95)
    static let electricCyan  = Color(red: 0.39, green: 0.82, blue: 1.00)
    static let mintAccent    = Color(red: 0.20, green: 0.90, blue: 0.60)
    static let cardSurface   = Color.white.opacity(0.07)
    static let borderSubtle  = Color.white.opacity(0.12)
}

// MARK: - Shared accent color set (replaces scattered [.pink, .blue, .purple, ...])

let appChartColors: [Color] = [.hotPink, .electricBlue, .neonPurple, .electricCyan, .mintAccent, Color(red: 1.0, green: 0.6, blue: 0.1)]

// MARK: - App Background

struct AppBackground: View {
    var body: some View {
        ZStack {
            Color.appBg
            RadialGradient(
                colors: [Color.electricBlue.opacity(0.18), .clear],
                center: .topLeading,
                startRadius: 0,
                endRadius: 400
            )
            RadialGradient(
                colors: [Color.hotPink.opacity(0.12), .clear],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 380
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass Card

struct GlassCard: ViewModifier {
    var cornerRadius: CGFloat = 20
    var accentColor: Color? = nil

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.white.opacity(0.07))
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(borderGradient, lineWidth: 1.2)
            )
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
    }

    private var borderGradient: LinearGradient {
        if let accent = accentColor {
            return LinearGradient(
                colors: [accent.opacity(0.7), accent.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
        return LinearGradient(
            colors: [Color.white.opacity(0.18), Color.white.opacity(0.05)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    func glassCard(cornerRadius: CGFloat = 20, accent: Color? = nil) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, accentColor: accent))
    }
}

// MARK: - Gradient Text

struct GradientLabel: View {
    let text: String
    let font: Font
    let colors: [Color]

    init(_ text: String, font: Font = .largeTitle.bold(), colors: [Color] = [.electricBlue, .hotPink]) {
        self.text = text
        self.font = font
        self.colors = colors
    }

    var body: some View {
        Text(text)
            .font(font)
            .foregroundStyle(
                LinearGradient(colors: colors, startPoint: .leading, endPoint: .trailing)
            )
    }
}

// MARK: - Glow Text

struct GlowText: View {
    let text: String
    let font: Font
    let color: Color
    var glowColors: [Color]
    var glowRadius: CGFloat = 10

    init(_ text: String, font: Font = .system(size: 22, weight: .semibold, design: .rounded), color: Color = Color.white.opacity(0.72), glowColors: [Color] = [.electricBlue, .hotPink]) {
        self.text = text
        self.font = font
        self.color = color
        self.glowColors = glowColors
    }

    var body: some View {
        ZStack {
            // Blurred gradient glow layer — follows letter shapes
            Text(text)
                .font(font)
                .foregroundStyle(
                    LinearGradient(colors: glowColors, startPoint: .leading, endPoint: .trailing)
                )
                .blur(radius: glowRadius)
                .opacity(0.7)

            // Crisp text on top
            Text(text)
                .font(font)
                .foregroundStyle(color)
                .tracking(0.5)
        }
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .foregroundStyle(Color.white.opacity(0.4))
            .textCase(.uppercase)
            .tracking(1.2)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
