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

    private let service     = HairAnalysisService()
    private let limitMgr    = ScanLimitManager.shared
    private let historyMgr  = ScanHistoryManager.shared

    var body: some View {

        ZStack {

            Color(red: 0.06, green: 0.04, blue: 0.12).ignoresSafeArea()

            // Colorful blobs
            Circle()
                .fill(Color(red: 0.90, green: 0.25, blue: 0.55).opacity(0.32))
                .frame(width: 340, height: 340)
                .blur(radius: 88)
                .offset(x: 120, y: -260)
                .ignoresSafeArea()

            Circle()
                .fill(Color(red: 0.45, green: 0.18, blue: 0.88).opacity(0.28))
                .frame(width: 280, height: 280)
                .blur(radius: 80)
                .offset(x: -110, y: -60)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {

                    // ── Header ────────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Hair Scan")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundStyle(LinearGradient(
                                colors: [.white, Color(red: 1.0, green: 0.75, blue: 0.90)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                        Text("Take or upload a photo of your scalp")
                            .font(.system(size: 14))
                            .foregroundColor(Color(red: 0.75, green: 0.60, blue: 0.90))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 16)

                    // ── First Scan Info Banner ────────────────────────────────
                    if limitMgr.isFirstScanEver {
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color(red: 0.35, green: 0.15, blue: 0.70).opacity(0.20))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "wand.and.stars")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(red: 0.75, green: 0.55, blue: 1.0))
                            }
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Welcome! Take your first scan")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.white)
                                Text("This becomes your baseline for tracking improvement over time.")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.55))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.35, green: 0.15, blue: 0.70).opacity(0.12))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color(red: 0.75, green: 0.55, blue: 1.0).opacity(0.20), lineWidth: 1)
                        )
                    } else {
                        // ── Weekly Scan Limit Badge ───────────────────────────
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(limitMgr.canScan
                                          ? Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15)
                                          : Color(red: 0.65, green: 0.15, blue: 0.15).opacity(0.15))
                                    .frame(width: 40, height: 40)
                                Image(systemName: limitMgr.canScan ? "camera.fill" : "lock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(limitMgr.canScan
                                                     ? Color(red: 0.55, green: 1.0, blue: 0.75)
                                                     : Color(red: 1.0, green: 0.45, blue: 0.45))
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(limitMgr.canScan ? "Weekly scans available" : "Weekly limit reached")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.white)
                                Text(limitMgr.canScan
                                     ? "\(limitMgr.scansRemaining) of 3 remaining this week"
                                     : "Resets in \(limitMgr.daysUntilReset) days")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.50))
                            }
                            Spacer()
                            HStack(spacing: 6) {
                                ForEach(0..<3) { i in
                                    Circle()
                                        .fill(i < limitMgr.scansThisWeek
                                              ? Color(red: 0.55, green: 1.0, blue: 0.75)
                                              : Color.white.opacity(0.15))
                                        .frame(width: 8, height: 8)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(limitMgr.canScan
                                        ? Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.15)
                                        : Color(red: 1.0, green: 0.45, blue: 0.45).opacity(0.30),
                                        lineWidth: 1)
                        )
                    }

                    // ── Image Preview ─────────────────────────────────────────
                    ZStack {
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.07), lineWidth: 1)
                            )

                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: 24))
                        } else {
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color(red: 0.10, green: 0.62, blue: 0.45).opacity(0.15))
                                        .frame(width: 80, height: 80)
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 32, weight: .light))
                                        .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                                }
                                Text("No image selected")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color.white.opacity(0.40))
                                Text("Take a photo or choose from gallery")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color.white.opacity(0.25))
                            }
                            .padding(40)
                        }
                    }
                    .frame(height: 300)
                    .scaleEffect(animateCard ? 1.0 : 0.95)
                    .opacity(animateCard ? 1.0 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.75), value: animateCard)

                    // ── Camera / Gallery Buttons ──────────────────────────────
                    HStack(spacing: 12) {

                        Button(action: { handleScanTap(source: .camera) }) {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Camera")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(LinearGradient(
                                colors: [Color(red: 0.90, green: 0.25, blue: 0.55),
                                         Color(red: 0.45, green: 0.18, blue: 0.88)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.80, green: 0.15, blue: 0.50).opacity(0.40), radius: 14, y: 6)
                            .opacity(!limitMgr.isFirstScanEver && !limitMgr.canScan ? 0.50 : 1.0)
                        }

                        Button(action: { handleScanTap(source: .photoLibrary) }) {
                            HStack(spacing: 10) {
                                Image(systemName: "photo.on.rectangle")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Gallery")
                                    .font(.system(size: 15, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.90, green: 0.65, blue: 1.0))
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color(red: 0.70, green: 0.45, blue: 1.0).opacity(0.35), lineWidth: 1.5)
                            )
                            .opacity(!limitMgr.isFirstScanEver && !limitMgr.canScan ? 0.50 : 1.0)
                        }
                    }

                    // ── Analyze Button ────────────────────────────────────────
                    if selectedImage != nil {
                        Button(action: analyzeHair) {
                            ZStack {
                                HStack(spacing: 10) {
                                    Image(systemName: "waveform.path.ecg")
                                        .font(.system(size: 16, weight: .semibold))
                                    Text("Analyze Hair")
                                        .font(.system(size: 17, weight: .bold, design: .rounded))
                                }
                                .foregroundColor(.white)
                                .opacity(isAnalyzing ? 0 : 1)

                                if isAnalyzing {
                                    HStack(spacing: 10) {
                                        SwiftUI.ProgressView().tint(.white)
                                        Text("Analyzing...")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(LinearGradient(
                                colors: [Color(red: 0.45, green: 0.18, blue: 0.88),
                                         Color(red: 0.90, green: 0.25, blue: 0.55)],
                                startPoint: .leading, endPoint: .trailing
                            ))
                            .cornerRadius(16)
                            .shadow(color: Color(red: 0.60, green: 0.15, blue: 0.70).opacity(0.50), radius: 18, y: 8)
                        }
                        .disabled(isAnalyzing)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // ── View Progress Button ──────────────────────────────────
                    if analysisResult != nil {
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.70)) {
                                selectedTab = 3
                            }
                        }) {
                            HStack(spacing: 10) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("View Your Progress")
                                    .font(.system(size: 16, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color(red: 0.55, green: 1.0, blue: 0.75).opacity(0.25), lineWidth: 1.5)
                            )
                        }
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    // ── Error Banner ──────────────────────────────────────────
                    if showError {
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                            Text(errorMessage)
                                .font(.system(size: 13))
                                .foregroundColor(Color(red: 1.0, green: 0.45, blue: 0.45))
                            Spacer()
                        }
                        .padding(14)
                        .background(Color(red: 1.0, green: 0.25, blue: 0.25).opacity(0.12))
                        .cornerRadius(12)
                        .transition(.opacity)
                    }

                    // ── Tips ──────────────────────────────────────────────────
                    VStack(alignment: .leading, spacing: 12) {
                        Text("SCAN TIPS")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Color(red: 0.55, green: 0.80, blue: 0.70))
                            .tracking(1.5)

                        VStack(spacing: 0) {
                            tipRow(icon: "sun.max.fill",
                                   text: "Use good lighting", isLast: false)
                            tipRow(icon: "arrow.up.to.line",
                                   text: "Hold camera 6-8 inches away", isLast: false)
                            tipRow(icon: "camera.metering.center.weighted",
                                   text: "Focus on the scalp area", isLast: true)
                        }
                        .background(Color(red: 0.10, green: 0.10, blue: 0.18))
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.07), lineWidth: 1)
                        )
                    }

                    Spacer().frame(height: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onAppear { animateCard = true }
        .navigationDestination(isPresented: $navigateToResult) {
            ResultView(result: analysisResult,
                       image: selectedImage,
                       comparisonText: comparisonResult)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $selectedImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $showCamera) {
            ImagePicker(image: $selectedImage, sourceType: .camera)
        }

        // Limit alert
        .alert("Weekly Limit Reached", isPresented: $showLimitAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("You've used all 3 scans for this week. Your limit resets in \(limitMgr.daysUntilReset) days. Rest and let your hair recover!")
        }

        // Confirm scan alert (after first scan)
        .alert("Ready to Scan?", isPresented: $showConfirmAlert) {
            Button("Yes, Scan Now") {
                if pendingSource == .camera {
                    showCamera = true
                } else {
                    showImagePicker = true
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will use 1 of your \(limitMgr.scansRemaining) remaining scans this week. For best comparison results, take the photo from the same angle and lighting as before.")
        }
    }

    // MARK: - Handle Scan Tap
    private func handleScanTap(source: UIImagePickerController.SourceType) {
        // First scan ever — no confirmation needed
        if limitMgr.isFirstScanEver {
            if source == .camera { showCamera = true }
            else { showImagePicker = true }
            return
        }

        // Check weekly limit
        if !limitMgr.canScan {
            showLimitAlert = true
            return
        }

        // Show confirmation for subsequent scans
        pendingSource    = source
        showConfirmAlert = true
    }

    // MARK: - Analyze
    private func analyzeHair() {
        guard let image = selectedImage else { return }
        isAnalyzing      = true
        showError        = false
        comparisonResult = ""

        service.analyzeHair(image: image) { result in
            switch result {
            case .success(let analysis):

                ScanHistoryManager.shared.saveScan(result: analysis, image: image)
                ScanLimitManager.shared.recordScan()

                // Auto compare with first scan if not first scan
                if let firstImage = ScanHistoryManager.shared.getFirstScanImage(),
                   ScanHistoryManager.shared.totalScans > 1 {

                    self.service.compareHair(before: firstImage, after: image) { compareResult in
                        self.isAnalyzing = false
                        if case .success(let text) = compareResult {
                            self.comparisonResult = text
                        }
                        self.analysisResult   = analysis
                        self.navigateToResult = true
                    }
                } else {
                    self.isAnalyzing      = false
                    self.analysisResult   = analysis
                    self.navigateToResult = true
                }

            case .failure(let error):
                self.isAnalyzing  = false
                self.errorMessage = error.localizedDescription
                self.showError    = true
            }
        }
    }

    // MARK: - Tip Row
    private func tipRow(icon: String, text: String, isLast: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(Color(red: 0.55, green: 1.0, blue: 0.75))
                .frame(width: 24)
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(Color.white.opacity(0.70))
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.06))
                .frame(height: 1),
            alignment: isLast ? .top : .bottom
        )
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
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

#Preview {
    NavigationStack {
        ScanView(selectedTab: .constant(1))
    }
}
