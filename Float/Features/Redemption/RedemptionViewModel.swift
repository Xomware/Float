// RedemptionViewModel.swift
// Float

import SwiftUI
import Supabase
import CryptoKit
import CoreImage.CIFilterBuiltins
import OSLog

private let logger = Logger(subsystem: "com.xomware.float", category: "Redemption")

struct Redemption: Identifiable, Codable {
    let id: UUID
    let dealId: UUID
    let userId: UUID
    let qrToken: String
    let redeemedAt: Date?
    let createdAt: Date
    let deal: Deal?  // joined
}

@MainActor
class RedemptionViewModel: ObservableObject {
    @Published var qrCode: UIImage?
    @Published var redemptionToken: String = ""
    @Published var isLoading = false
    @Published var error: String?
    @Published var successAnimation = false
    @Published var redemptions: [Redemption] = []
    
    private let supabaseClient = SupabaseClientService.shared.client
    
    // MARK: - QR Code Generation
    func generateQRCode(for token: String) {
        guard let data = token.data(using: .utf8) else { return }
        let filter = CIFilter.qrCodeGenerator()
        filter.setValue(data, forKey: "inputMessage")
        
        guard let ciImage = filter.outputImage else { return }
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledCIImage = ciImage.transformed(by: transform)
        
        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledCIImage, from: scaledCIImage.extent) else { return }
        
        DispatchQueue.main.async {
            self.qrCode = UIImage(cgImage: cgImage)
        }
    }
    
    // MARK: - Redemption Creation
    func redeemDeal(_ deal: Deal, userId: UUID) async {
        isLoading = true
        error = nil
        
        do {
            // Generate unique QR token
            let token = UUID().uuidString.replacingOccurrences(of: "-", with: "").prefix(32).lowercased()
            redemptionToken = String(token)
            
            // Insert redemption record
            let redemption: [String: AnyCodable] = [
                "user_id": AnyCodable(userId.uuidString),
                "deal_id": AnyCodable(deal.id.uuidString),
                "venue_id": AnyCodable(deal.venueId.uuidString),
                "qr_token": AnyCodable(String(token)),
                "status": AnyCodable("pending")
            ]
            
            // This would normally call Supabase insert
            // For now, just generate QR code
            generateQRCode(for: String(token))
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.successAnimation = true
            }
            
            logger.info("Redemption created for deal: \(deal.id)")
        } catch {
            self.error = error.localizedDescription
            logger.error("Redemption error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
    
    // MARK: - Load Redemption History
    func loadRedemptionHistory(userId: UUID) async {
        isLoading = true
        error = nil
        
        do {
            // Mock fetch - would call Supabase in production
            self.redemptions = []
            
            logger.info("Loaded redemption history")
        } catch {
            self.error = error.localizedDescription
            logger.error("History load error: \(error.localizedDescription)")
        }
        
        isLoading = false
    }
}

// Helper to encode/decode any type for Supabase
struct AnyCodable: Codable {
    let value: Codable
    
    init(_ value: Codable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        if let int = value as? Int {
            var container = encoder.singleValueContainer()
            try container.encode(int)
        } else if let string = value as? String {
            var container = encoder.singleValueContainer()
            try container.encode(string)
        } else if let bool = value as? Bool {
            var container = encoder.singleValueContainer()
            try container.encode(bool)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode")
        }
    }
}
