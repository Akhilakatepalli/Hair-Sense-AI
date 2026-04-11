//
//  ScanView.swift
//  Hair AI
//

import SwiftUI
import PhotosUI

struct ScanView: View {

    @Binding var selectedTab: Int
    @State private var selectedImage: UIImage?              = nil
    @State private var showImagePicker                      = false
    @State private var showCamera                           = false
    @State private var isAnalyzing                         = false
    @State private var animateCard                         = false
    @State private var errorMessage                        = ""
    @State private var showError                           = false
    @State private var analysisResult: HairAnalysisResult? = nil
    @State private var navigateToResult                    = false
    @State private var comparisonResult                    = ""
    @State private var showLimitAlert                      = false
    @State private var showConfirmAlert                    = false
    @State private var pendingSource: UIImagePickerController.SourceType = .photoLibrary
    @State private var pulseScale: CGFloat                 = 1.0
    @State private var scanRotation: Double                = 0.0

    private let service    = HairAnalysisService()
    private let limitMgr   = ScanLimitManager.shared
    private let historyMgr = ScanHistoryManager.shared

    var body: some View {
        ZStack {
            AnimatedTabBackground(theme: .scan)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    // ── Header ────────────────────────────────────────────────
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("AI Hair Scan")
                                .font(.system(size: 30, weight: .bold, design: .rounded))
                                .foregroundStyle(LinearGradient(
                                    colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.92)],
                                    startPoint: .leading, endPoint: .trailing
                                ))
                            Text("Powered by advanced AI analysis")
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.90))
                        }
                        Spacer()
                        HStack(spacing: 5) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 10, weight: .bold))
                            Text("AI")
                                .font(.system(size: 12, weight: .heavy))
                        }
                        .foregroundColor(Color(red: 0.90, green: 0.65, blue: 1.0))
                        .padding(.horizontal, 12).padding(.vertical, 7)
                        .background(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.28))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color(red: 0.75, green: 0.50, blue: 1.0).opacity(0.35), lineWidth: 1))
                    }
                    .padding(.top, 16)

                    // ── Scan Limit Badge ──────────────────────────────────────
                    scanLimitBadge

                    // ── Image Preview ─────────────────────────────────────────
                    scanPreviewArea
                        .scaleEffect(animateCard ? 1.0 : 0.94)
                        .opacity(animateCard ? 1.0 : 0)
                        .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animateCard)

                    // ── Action Buttons ────────────────────────────────────────
                    actionButtons

                    // ── Analyze Button ────────────────────────────────────────
                    if selectedImage != nil {
                        analyzeButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // ── View Progress ─────────────────────────────────────────
                    if analysisResult != nil {
                        viewProgressButton
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // ── Error ─────────────────────────────────────────────────
                    if showError {
                        errorBanner.transition(.opacity)
                    }

                    // ── How It Works ──────────────────────────────────────────
                    howItWorksSection

                    // ── Tips ──────────────────────────────────────────────────
                    tipsSection

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear {
            animateCard = true
            withAnimation(.easeInOut(duration: 2.2).repeatForever(autoreverses: true)) {
                pulseScale = 1.14
            }
            withAnimation(.linear(duration: 5.5).repeatForever(autoreverses: false)) {
                scanRotation = 360
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(result: analysisResult, image: selectedImage, comparisonText: comparisonResult)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }
        .alert("Weekly Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've used all 3 scans for this week. Your limit resets in \(limitMgr.daysUntilReset) days. Rest and let your hair recover!")
        }
        .alert("Ready to Scan?", isPresented: $showConfirmAlert) {
            Button("Yes, Scan Now") {
                if pendingSource == .camera { showCamera = true } else { showImagePicker = true }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will use 1 of your \(limitMgr.scansRemaining) remaining scans this week. For best results, same angle and lighting as before.")
        }
    }

    // MARK: - Scan Limit Badge

    private var scanLimitBadge: some View {
        Group {
            if limitMgr.isFirstScanEver { firstScanBanner } else { weeklyLimitBar }
        }
    }

    private var firstScanBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color(red: 0.45, green: 0.18, blue: 0.88), Color(red: 0.90, green: 0.25, blue: 0.55)],
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ))
                    .frame(width: 48, height: 48)
                Image(systemName: "wand.and.stars")
                    .font(.system(size: 20))
                    .foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Welcome! Take Your First Scan")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.white)
                Text("This becomes your baseline for tracking improvement.")
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(16)
        .background(LinearGradient(
            colors: [Color(red: 0.20, green: 0.08, blue: 0.42).opacity(0.85), Color(red: 0.10, green: 0.06, blue: 0.26).opacity(0.85)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        ))
        .cornerRadius(18)
        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color(red: 0.75, green: 0.55, blue: 1.0).opacity(0.28), lineWidth: 1))
    }

    private var weeklyLimitBar: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(limitMgr.canScan
                          ? Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.22)
                          : Color(red: 0.65, green: 0.15, blue: 0.15).opacity(0.22))
                    .frame(width: 44, height: 44)
                Image(systemName: limitMgr.canScan ? "checkmark.seal.fill" : "lock.fill")
                    .font(.system(size: 18))
                    .foregroundColor(limitMgr.canScan
                                     ? Color(red: 0.35, green: 1.0, blue: 0.68)
                                     : Color(red: 1.0, green: 0.45, blue: 0.45))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(limitMgr.canScan ? "Scans Available" : "Weekly Limit Reached")
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text(limitMgr.canScan
                     ? "\(limitMgr.scansRemaining) of 3 remaining this week"
                     : "Resets in \(limitMgr.daysUntilReset) days")
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.50))
            }
            Spacer()
            HStack(spacing: 7) {
                ForEach(0..<3) { i in
                    ZStack {
                        if i < limitMgr.scansThisWeek {
                            Circle()
                                .fill(Color(red: 0.35, green: 1.0, blue: 0.68).opacity(0.25))
                                .frame(width: 16, height: 16)
                        }
                        Circle()
                            .fill(i < limitMgr.scansThisWeek
                                  ? Color(red: 0.35, green: 1.0, blue: 0.68)
                                  : Color.white.opacity(0.12))
                            .frame(width: 9, height: 9)
                    }
                }
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
        .glassCard(cornerRadius: 18, tint: limitMgr.canScan
            ? Color(red: 0.35, green: 1.0, blue: 0.68)
            : Color(red: 1.0, green: 0.45, blue: 0.45))
    }

    // MARK: - Scan Preview Area

    private var scanPreviewArea: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(Color(red: 0.08, green: 0.06, blue: 0.18))
                .overlay(RoundedRectangle(cornerRadius: 28).stroke(Color.white.opacity(0.08), lineWidth: 1))

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable().scaledToFill()
                    .frame(maxWidth: .infinity).frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 28))

                if isAnalyzing {
                    ZStack {
                        Color.black.opacity(0.60).cornerRadius(28)
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .stroke(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.18), lineWidth: 2.5)
                                    .frame(width: 76, height: 76)
                                Circle()
                                    .trim(from: 0, to: 0.70)
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88)],
                                            startPoint: .leading, endPoint: .trailing
                                        ),
                                        style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                                    )
                                    .frame(width: 76, height: 76)
                                    .rotationEffect(.degrees(scanRotation))
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 24)).foregroundColor(.white)
                            }
                            Text("AI Analyzing...")
                                .font(.system(size: 15, weight: .bold, design: .rounded)).foregroundColor(.white)
                            Text("Reading scalp patterns & follicle health")
                                .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.55))
                        }
                    }
                }
            } else {
                VStack(spacing: 22) {
                    ZStack {
                        // Outer pulse rings
                        Circle()
                            .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.05))
                            .frame(width: 148, height: 148)
                            .scaleEffect(pulseScale)
                        Circle()
                            .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.09))
                            .frame(width: 116, height: 116)
                            .scaleEffect(pulseScale * 0.94)
                        // Rotating arc
                        Circle()
                            .trim(from: 0, to: 0.68)
                            .stroke(
                                LinearGradient(
                                    colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.45, green: 0.18, blue: 0.88), Color.clear],
                                    startPoint: .leading, endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 2.5, lineCap: .round)
                            )
                            .frame(width: 88, height: 88)
                            .rotationEffect(.degrees(scanRotation))
                        // Static ring
                        Circle()
                            .stroke(Color.white.opacity(0.06), lineWidth: 1.5)
                            .frame(width: 88, height: 88)
                        // Inner filled circle
                        Circle()
                            .fill(LinearGradient(
                                colors: [Color(red: 0.20, green: 0.10, blue: 0.36), Color(red: 0.12, green: 0.08, blue: 0.24)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            ))
                            .frame(width: 74, height: 74)
                        // Icon
                        Image(systemName: "camera.viewfinder")
                            .font(.system(size: 28, weight: .light))
                            .foregroundStyle(LinearGradient(
                                colors: [Color(red: 0.95, green: 0.55, blue: 0.82), Color(red: 0.72, green: 0.40, blue: 1.0)],
                                startPoint: .top, endPoint: .bottom
                            ))
                    }
                    VStack(spacing: 6) {
                        Text("Ready to Scan")
                            .font(.system(size: 18, weight: .bold, design: .rounded)).foregroundColor(.white)
                        Text("Take a photo or choose from gallery")
                            .font(.system(size: 13)).foregroundColor(Color.white.opacity(0.38))
                    }
                }
                .padding(40)
            }
        }
        .frame(height: 300)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button(action: { handleScanTap(source: .camera) }) {
                HStack(spacing: 9) {
                    Image(systemName: "camera.fill").font(.system(size: 15, weight: .semibold))
                    Text("Camera").font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(LinearGradient(
                    colors: [Color(red: 0.90, green: 0.25, blue: 0.55), Color(red: 0.65, green: 0.18, blue: 0.85)],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                ))
                .cornerRadius(17)
                .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.42), radius: 14, y: 6)
                .opacity(!limitMgr.isFirstScanEver && !limitMgr.canScan ? 0.40 : 1.0)
            }

            Button(action: { handleScanTap(source: .photoLibrary) }) {
                HStack(spacing: 9) {
                    Image(systemName: "photo.on.rectangle").font(.system(size: 15, weight: .semibold))
                    Text("Gallery").font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(Color(red: 0.85, green: 0.65, blue: 1.0))
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.18))
                .cornerRadius(17)
                .overlay(RoundedRectangle(cornerRadius: 17)
                    .stroke(Color(red: 0.70, green: 0.45, blue: 1.0).opacity(0.40), lineWidth: 1.5))
                .opacity(!limitMgr.isFirstScanEver && !limitMgr.canScan ? 0.40 : 1.0)
            }
        }
    }

    // MARK: - Analyze Button

    private var analyzeButton: some View {
        Button(action: analyzeHair) {
            ZStack {
                HStack(spacing: 10) {
                    Image(systemName: "waveform.path.ecg").font(.system(size: 16, weight: .semibold))
                    Text("Analyze Hair").font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundColor(.white)
                .opacity(isAnalyzing ? 0 : 1)

                if isAnalyzing {
                    HStack(spacing: 10) {
                        SwiftUI.ProgressView().tint(.white)
                        Text("Analyzing...").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)
                    }
                }
            }
            .frame(maxWidth: .infinity).frame(height: 58)
            .background(LinearGradient(
                colors: [Color(red: 0.45, green: 0.18, blue: 0.88), Color(red: 0.90, green: 0.25, blue: 0.55)],
                startPoint: .leading, endPoint: .trailing
            ))
            .cornerRadius(18)
            .shadow(color: Color(red: 0.60, green: 0.15, blue: 0.70).opacity(0.55), radius: 20, y: 8)
        }
        .disabled(isAnalyzing)
    }

    // MARK: - View Progress Button

    private var viewProgressButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) { selectedTab = 2 }
        }) {
            HStack(spacing: 10) {
                Image(systemName: "chart.bar.fill").font(.system(size: 15, weight: .semibold))
                Text("View Your Progress").font(.system(size: 16, weight: .bold, design: .rounded))
                Spacer()
                Image(systemName: "arrow.right").font(.system(size: 13, weight: .semibold))
            }
            .foregroundColor(Color(red: 0.35, green: 1.0, blue: 0.68))
            .frame(maxWidth: .infinity).frame(height: 52)
            .background(Color(red: 0.07, green: 0.24, blue: 0.17))
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15)
                .stroke(Color(red: 0.35, green: 1.0, blue: 0.68).opacity(0.28), lineWidth: 1.5))
        }
    }

    // MARK: - Error Banner

    private var errorBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
            Text(errorMessage)
                .font(.system(size: 13))
                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
            Spacer()
        }
        .padding(14)
        .background(Color(red: 0.22, green: 0.05, blue: 0.05))
        .cornerRadius(12)
        .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(Color(red: 1.0, green: 0.45, blue: 0.45).opacity(0.30), lineWidth: 1))
    }

    // MARK: - How It Works

    private var howItWorksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("HOW IT WORKS")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(Color(red: 0.80, green: 0.65, blue: 1.0))
                    .tracking(1.5)
                Spacer()
            }
            HStack(spacing: 10) {
                howItWorksStep(
                    icon: "camera.fill",
                    title: "Capture",
                    subtitle: "Clear scalp photo in good light",
                    color: Color(red: 0.90, green: 0.25, blue: 0.55)
                )
                // Arrow connector
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.22))
                howItWorksStep(
                    icon: "brain.head.profile",
                    title: "Analyze",
                    subtitle: "AI scans 12+ health markers",
                    color: Color(red: 0.45, green: 0.18, blue: 0.88)
                )
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Color.white.opacity(0.22))
                howItWorksStep(
                    icon: "chart.bar.fill",
                    title: "Insights",
                    subtitle: "Personalised recommendations",
                    color: Color(red: 0.10, green: 0.78, blue: 0.55)
                )
            }
        }
    }

    private func howItWorksStep(icon: String, title: String, subtitle: String, color: Color) -> some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.18))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(color.opacity(0.25), lineWidth: 1))
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(spacing: 3) {
                Text(title)
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text(subtitle)
                    .font(.system(size: 10)).foregroundColor(Color.white.opacity(0.42))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16).padding(.horizontal, 6)
        .background(color.opacity(0.07))
        .cornerRadius(16)
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(color.opacity(0.20), lineWidth: 1))
    }

    // MARK: - Tips Section

    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("SCAN TIPS")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(Color(red: 0.55, green: 0.82, blue: 0.70))
                .tracking(1.5)

            VStack(spacing: 8) {
                tipCard(
                    icon: "sun.max.fill",
                    title: "Good Lighting",
                    text: "Natural light or bright lamp gives the clearest results",
                    color: Color(red: 1.0, green: 0.72, blue: 0.20)
                )
                tipCard(
                    icon: "arrow.up.to.line",
                    title: "Correct Distance",
                    text: "Hold 6–8 inches from scalp for optimal focus",
                    color: Color(red: 0.45, green: 0.75, blue: 1.0)
                )
                tipCard(
                    icon: "camera.metering.center.weighted",
                    title: "Scalp Focus",
                    text: "Part your hair to reveal the scalp and centre the shot",
                    color: Color(red: 0.35, green: 1.0, blue: 0.68)
                )
            }
        }
    }

    private func tipCard(icon: String, title: String, text: String, color: Color) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.16))
                    .frame(width: 46, height: 46)
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                Text(text)
                    .font(.system(size: 12)).foregroundColor(Color.white.opacity(0.48))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(14)
        .background(color.opacity(0.06))
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(color.opacity(0.18), lineWidth: 1))
    }

    // MARK: - Handle Scan Tap
    private func handleScanTap(source: UIImagePickerController.SourceType) {
        if limitMgr.isFirstScanEver {
            if source == .camera { showCamera = true } else { showImagePicker = true }
            return
        }
        if !limitMgr.canScan { showLimitAlert = true; return }
        pendingSource = source
        showConfirmAlert = true
    }

    // MARK: - Analyze
    private func analyzeHair() {
        guard let image = selectedImage else { return }
        isAnalyzing = true; showError = false; comparisonResult = ""

        service.analyzeHair(image: image) { result in
            switch result {
            case .success(let analysis):
                ScanHistoryManager.shared.saveScan(result: analysis, image: image)
                ScanLimitManager.shared.recordScan()

                if let firstImage = ScanHistoryManager.shared.getFirstScanImage(),
                   ScanHistoryManager.shared.totalScans > 1 {
                    self.service.compareHair(before: firstImage, after: image) { compareResult in
                        self.isAnalyzing = false
                        if case .success(let text) = compareResult { self.comparisonResult = text }
                        self.analysisResult = analysis; self.navigateToResult = true
                    }
                } else {
                    self.isAnalyzing = false; self.analysisResult = analysis; self.navigateToResult = true
                }

            case .failure(let error):
                self.isAnalyzing = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}

// MARK: - ImagePicker

struct ImagePicker: UIViewControllerRepresentable {

    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate   = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage { parent.image = image }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) { parent.dismiss() }
    }
}

#Preview {
    NavigationStack { ScanView(selectedTab: .constant(3)) }
}
