import SwiftUI

enum NammaColor {
    static let cream = Color(red: 0.99, green: 0.95, blue: 0.87)
    static let warmSand = Color(red: 0.96, green: 0.88, blue: 0.74)
    static let card = Color(red: 1.0, green: 0.98, blue: 0.93)
    static let cardPeach = Color(red: 0.99, green: 0.90, blue: 0.80)
    static let cardLeaf = Color(red: 0.90, green: 0.94, blue: 0.78)
    static let cardSky = Color(red: 0.88, green: 0.94, blue: 0.93)
    static let deepGreen = Color(red: 0.05, green: 0.34, blue: 0.24)
    static let leaf = Color(red: 0.18, green: 0.48, blue: 0.30)
    static let moss = Color(red: 0.47, green: 0.57, blue: 0.31)
    static let terracotta = Color(red: 0.82, green: 0.35, blue: 0.16)
    static let saffron = Color(red: 0.94, green: 0.57, blue: 0.16)
    static let rose = Color(red: 0.83, green: 0.27, blue: 0.39)
    static let teal = Color(red: 0.21, green: 0.47, blue: 0.49)
    static let ink = Color(red: 0.12, green: 0.10, blue: 0.08)
    static let muted = Color(red: 0.43, green: 0.39, blue: 0.33)
    static let line = Color(red: 0.78, green: 0.64, blue: 0.47)
    static let danger = Color(red: 0.70, green: 0.16, blue: 0.12)
}

enum FitColor {
    static func color(for fit: FitLabel) -> Color {
        switch fit {
        case .green: return NammaColor.leaf
        case .yellow: return NammaColor.saffron
        case .red: return NammaColor.rose
        }
    }
}

enum NammaCardTone {
    case base
    case leaf
    case peach
    case sky
    case hero

    var background: Color {
        switch self {
        case .base: return NammaColor.card
        case .leaf: return NammaColor.cardLeaf
        case .peach: return NammaColor.cardPeach
        case .sky: return NammaColor.cardSky
        case .hero: return Color(red: 1.0, green: 0.94, blue: 0.84)
        }
    }
}

struct NammaBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                NammaColor.cream,
                Color(red: 0.99, green: 0.91, blue: 0.79),
                Color(red: 0.94, green: 0.97, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(alignment: .topTrailing) {
            BotanicalCluster()
                .frame(width: 160, height: 140)
                .opacity(0.20)
                .padding(.top, 12)
                .padding(.trailing, -28)
        }
        .overlay(alignment: .bottomLeading) {
            LeafSprig()
                .frame(width: 150, height: 120)
                .opacity(0.16)
                .padding(.leading, -30)
                .padding(.bottom, 18)
        }
    }
}

struct SectionCard<Content: View>: View {
    let content: Content
    let tone: NammaCardTone

    init(tone: NammaCardTone = .base, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.tone = tone
    }

    var body: some View {
        content
            .padding(16)
            .background(tone.background)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(NammaColor.line.opacity(0.28), lineWidth: 1)
            }
            .shadow(color: NammaColor.deepGreen.opacity(0.08), radius: 18, x: 0, y: 10)
    }
}

struct ScorePill: View {
    let title: String
    let value: Int

    var body: some View {
        HStack(spacing: 10) {
            Text(title)
                .foregroundStyle(NammaColor.muted)
            Spacer()
            Text("\(value)/10")
                .fontWeight(.semibold)
                .foregroundStyle(NammaColor.deepGreen)
        }
        .font(.caption)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.white.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(alignment: .bottomLeading) {
            GeometryReader { proxy in
                Capsule()
                    .fill(FitColor.color(for: value >= 7 ? FitLabel.green : value >= 5 ? FitLabel.yellow : FitLabel.red))
                    .frame(width: proxy.size.width * CGFloat(value) / 10, height: 3)
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
    }
}

struct NammaScreenHeader: View {
    let eyebrow: String
    let title: String
    let subtitle: String
    let systemImage: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(NammaColor.deepGreen)
                Image(systemName: systemImage)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(NammaColor.cream)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 4) {
                Text(eyebrow.uppercased())
                    .font(.caption.weight(.bold))
                    .foregroundStyle(NammaColor.terracotta)
                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(NammaColor.ink)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(NammaColor.muted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct NammaBadge: View {
    let text: String
    let systemImage: String?
    var tone: Color = NammaColor.deepGreen

    var body: some View {
        HStack(spacing: 6) {
            if let systemImage {
                Image(systemName: systemImage)
            }
            Text(text)
        }
        .font(.caption.weight(.semibold))
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .foregroundStyle(tone)
        .background(tone.opacity(0.12))
        .clipShape(Capsule())
    }
}

struct NammaProgressBar: View {
    let value: Double
    var tint: Color = NammaColor.saffron

    private var clampedValue: Double {
        min(max(value, 0), 1)
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(NammaColor.line.opacity(0.18))
                Capsule()
                    .fill(tint)
                    .frame(width: proxy.size.width * clampedValue)
            }
        }
        .frame(height: 8)
    }
}

struct NammaPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(NammaColor.cream)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? NammaColor.leaf : NammaColor.deepGreen)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: NammaColor.deepGreen.opacity(configuration.isPressed ? 0.08 : 0.18), radius: 10, x: 0, y: 6)
    }
}

struct NammaSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .foregroundStyle(NammaColor.deepGreen)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(.white.opacity(configuration.isPressed ? 0.48 : 0.72))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(NammaColor.deepGreen.opacity(0.14), lineWidth: 1)
            }
    }
}

struct NammaBrandMark: View {
    var body: some View {
        Image("AppBrandMark")
            .resizable()
            .scaledToFit()
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.42), lineWidth: 1)
            }
            .shadow(color: NammaColor.deepGreen.opacity(0.12), radius: 8, x: 0, y: 4)
        .frame(width: 46, height: 46)
    }
}

struct BengaluruIllustrationView: View {
    enum Scene: Equatable {
        case home
        case locality
        case lesson
        case community
        case quest
        case rent
    }

    let scene: Scene

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.white.opacity(0.36), NammaColor.cardPeach.opacity(0.7)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(scene.assetName)
                .resizable()
                .scaledToFit()
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
        }
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.42), lineWidth: 1)
        }
    }
}

extension BengaluruIllustrationView.Scene {
    var assetName: String {
        switch self {
        case .home: return "FeatureCity"
        case .locality: return "FeatureLocality"
        case .lesson: return "FeatureLesson"
        case .community: return "FeatureMentor"
        case .quest: return "FeatureQuest"
        case .rent: return "FeatureRent"
        }
    }
}

private struct BotanicalCluster: View {
    var body: some View {
        ZStack {
            ForEach(0..<7) { index in
                LeafShape()
                    .fill(index.isMultiple(of: 2) ? NammaColor.leaf : NammaColor.rose)
                    .frame(width: 34, height: 48)
                    .rotationEffect(.degrees(Double(index) * 38 - 80))
                    .offset(x: CGFloat(index % 3) * 30 - 26, y: CGFloat(index) * 8 - 26)
            }
        }
    }
}

private struct LeafSprig: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(NammaColor.line.opacity(0.7))
                .frame(width: 4, height: 112)
                .rotationEffect(.degrees(28))
            ForEach(0..<5) { index in
                LeafShape()
                    .fill(index.isMultiple(of: 2) ? NammaColor.deepGreen : NammaColor.moss)
                    .frame(width: 30, height: 44)
                    .rotationEffect(.degrees(index.isMultiple(of: 2) ? -28 : 28))
                    .offset(x: index.isMultiple(of: 2) ? -18 : 18, y: CGFloat(index) * 18 - 38)
            }
        }
    }
}

private struct LeafShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.minX - rect.width * 0.22, y: rect.height * 0.22),
            control2: CGPoint(x: rect.minX + rect.width * 0.08, y: rect.height * 0.84)
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY),
            control1: CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.height * 0.84),
            control2: CGPoint(x: rect.maxX + rect.width * 0.22, y: rect.height * 0.22)
        )
        return path
    }
}

private struct SkylineStrip: View {
    private let heights: [CGFloat] = [46, 62, 38, 78, 54, 68]

    var body: some View {
        HStack(alignment: .bottom, spacing: 7) {
            ForEach(Array(heights.enumerated()), id: \.offset) { index, height in
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(index.isMultiple(of: 2) ? NammaColor.teal.opacity(0.40) : NammaColor.saffron.opacity(0.30))
                        .frame(height: height)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

private struct RoadStrip: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(NammaColor.deepGreen.opacity(0.12))
            HStack(spacing: 18) {
                ForEach(0..<7) { _ in
                    Capsule()
                        .fill(NammaColor.cream.opacity(0.9))
                        .frame(width: 24, height: 3)
                }
            }
        }
    }
}

private struct AutoBadge: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(NammaColor.saffron)
                .frame(width: 66, height: 38)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(NammaColor.deepGreen)
                .frame(width: 54, height: 28)
            HStack(spacing: 28) {
                Circle().fill(NammaColor.ink).frame(width: 10, height: 10)
                Circle().fill(NammaColor.ink).frame(width: 10, height: 10)
            }
            .offset(y: 5)
            Rectangle()
                .fill(NammaColor.cream.opacity(0.78))
                .frame(width: 30, height: 10)
                .offset(y: -15)
        }
        .frame(width: 74, height: 54)
    }
}

private struct TreeCluster: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            Capsule()
                .fill(NammaColor.terracotta.opacity(0.7))
                .frame(width: 8, height: 36)
            HStack(spacing: -8) {
                Circle()
                    .fill(NammaColor.deepGreen)
                    .frame(width: 36, height: 36)
                Circle()
                    .fill(NammaColor.leaf)
                    .frame(width: 44, height: 44)
                Circle()
                    .fill(NammaColor.moss)
                    .frame(width: 30, height: 30)
            }
            .offset(y: -22)
        }
    }
}
