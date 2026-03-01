// SearchBarView.swift
// Float

import SwiftUI

struct SearchBarView: View {
    @Binding var text: String
    var placeholder: String = "Search deals…"
    var onCommit: (() -> Void)? = nil

    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: FloatSpacing.sm) {
            HStack(spacing: FloatSpacing.sm) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(FloatColors.adaptiveTextSecondary)

                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .font(FloatFont.body())
                    .foregroundStyle(FloatColors.adaptiveTextPrimary)
                    .submitLabel(.search)
                    .onSubmit { onCommit?() }

                if !text.isEmpty {
                    Button {
                        text = ""
                        isFocused = true
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(FloatColors.adaptiveTextSecondary)
                    }
                    .accessibilityLabel("Clear search")
                }

                // Microphone placeholder
                Image(systemName: "mic.fill")
                    .foregroundStyle(FloatColors.adaptiveTextSecondary.opacity(0.5))
                    .accessibilityLabel("Voice search")
            }
            .padding(10)
            .background(FloatColors.adaptiveCardBackground)
            .cornerRadius(12)
        }
        .padding(.horizontal, FloatSpacing.md)
        .padding(.vertical, FloatSpacing.sm)
    }
}
