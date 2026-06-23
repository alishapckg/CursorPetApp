import SwiftUI
import AppKit

struct GiphyPickerView: View {
  @StateObject private var manager = GiphyManager()
  @State private var searchText = ""
  @State private var selectedGif: GiphyItem?
  @State private var isDownloading = false

  @Environment(\.dismiss) private var dismiss

  let buddyState: BuddyState
  let onSelect: () -> Void

  private let accent = Color(hex: "#00FF88")
  private let bg = Color(hex: "#141118")

  private var columns: [GridItem] {
    [.init(.adaptive(minimum: 120, maximum: 160), spacing: 8)]
  }

  var body: some View {
    VStack(spacing: 0) {
      // Header
      HStack {
        Text("GIPHY")
          .font(.system(size: 15, weight: .semibold))
          .foregroundColor(.white.opacity(0.9))
        Spacer()
        Button { dismiss() } label: {
          Image(systemName: "xmark.circle.fill")
            .font(.system(size: 20))
            .foregroundColor(.white.opacity(0.4))
        }
        .buttonStyle(.plain)
        .help("Close")
      }
      .padding(.horizontal, 16)
      .padding(.top, 14)
      .padding(.bottom, 8)

      // Search
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.white.opacity(0.4))
        TextField("Search GIFs…", text: $searchText)
          .textFieldStyle(.plain)
          .font(.system(size: 14))
          .foregroundColor(.white)
          .onSubmit { performSearch() }
        if !searchText.isEmpty {
          Button { searchText = ""; performSearch() } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.white.opacity(0.4))
          }
          .buttonStyle(.plain)
        }
      }
      .padding(10)
      .background(Color.white.opacity(0.06))
      .cornerRadius(8)
      .overlay(
        RoundedRectangle(cornerRadius: 8)
          .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
      )
      .padding(.horizontal, 16)
      .padding(.bottom, 8)

      // Content
      if manager.isLoading && !isDownloading {
        Spacer()
        ProgressView()
          .progressViewStyle(.circular)
          .scaleEffect(0.8)
          .tint(accent)
        Spacer()
      } else if let error = manager.error {
        Spacer()
        VStack(spacing: 8) {
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 28))
            .foregroundColor(Color(hex: "#FFB800"))
          Text(error)
            .font(.system(size: 12))
            .foregroundColor(.white.opacity(0.6))
            .multilineTextAlignment(.center)
          Button("Retry") { performSearch() }
            .buttonStyle(.plain)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(accent)
            .padding(.horizontal, 16)
            .padding(.vertical, 6)
            .background(accent.opacity(0.12))
            .cornerRadius(6)
        }
        Spacer()
      } else {
        scrollGrid
      }
    }
    .frame(width: 420, height: 500)
    .background(bg)
    .task { await manager.fetchTrending() }
  }

  // MARK: - Grid

  private var scrollGrid: some View {
    let items = searchText.isEmpty ? manager.trendingGifs : manager.searchResults
    let hasMore = searchText.isEmpty ? manager.hasMoreTrending : manager.hasMoreSearch

    return ScrollView {
      LazyVGrid(columns: columns, spacing: 8) {
        ForEach(items) { item in
          GiphyCell(item: item, isSelected: selectedGif?.id == item.id)
            .onTapGesture { selectGif(item) }
        }

        if hasMore {
          Color.clear
            .frame(height: 1)
            .onAppear { loadMore() }
        }

        if manager.isLoadingMore {
          ProgressView()
            .progressViewStyle(.circular)
            .scaleEffect(0.6)
            .tint(accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
    }
  }

  // MARK: - Actions

  private func performSearch() {
    Task {
      if searchText.isEmpty {
        await manager.fetchTrending()
      } else {
        await manager.search(query: searchText)
      }
    }
  }

  private func loadMore() {
    Task {
      if searchText.isEmpty {
        await manager.loadMoreTrending()
      } else {
        await manager.loadMoreSearch()
      }
    }
  }

  private func selectGif(_ item: GiphyItem) {
    selectedGif = item
    isDownloading = true

    Task {
      guard let urlString = item.images.original.url,
            let url = URL(string: urlString) else {
        isDownloading = false
        return
      }

      do {
        let (data, _) = try await URLSession.shared.data(from: url)
        let tempDir = FileManager.default.temporaryDirectory
        let tempURL = tempDir.appendingPathComponent("\(item.id).gif")
        try data.write(to: tempURL)

        FileStorageService.shared.setCustomFile(url: tempURL, for: buddyState)
        try? FileManager.default.removeItem(at: tempURL)

        isDownloading = false
        onSelect()
        dismiss()
      } catch {
        isDownloading = false
      }
    }
  }
}

// MARK: - Cell

private struct GiphyCell: View {
  let item: GiphyItem
  let isSelected: Bool

  @State private var nsImage: NSImage?

  private let accent = Color(hex: "#00FF88")

  var body: some View {
    ZStack(alignment: .bottomTrailing) {
      Group {
        if let img = nsImage {
          Image(nsImage: img)
            .resizable()
            .aspectRatio(contentMode: .fill)
        } else {
          Rectangle()
            .fill(Color.white.opacity(0.08))
            .overlay(
              ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(0.5)
                .tint(.white.opacity(0.4))
            )
        }
      }

      if isSelected {
        Image(systemName: "checkmark.circle.fill")
          .font(.system(size: 18))
          .foregroundColor(accent)
          .background(Circle().fill(Color(hex: "#141118")).frame(width: 16, height: 16))
          .offset(x: -4, y: -4)
      }
    }
    .frame(height: 120)
    .clipped()
    .cornerRadius(8)
    .overlay(
      RoundedRectangle(cornerRadius: 8)
        .strokeBorder(isSelected ? accent : Color.white.opacity(0.08),
                     lineWidth: isSelected ? 2 : 0.5)
    )
    .contentShape(Rectangle())
    .task { await loadImage() }
  }

  private func loadImage() async {
    let urlString = item.images.fixedWidth?.url ?? item.images.downsized?.url ?? item.images.original.url
    guard let urlString, let url = URL(string: urlString) else { return }

    do {
      let (data, _) = try await URLSession.shared.data(from: url)
      nsImage = NSImage(data: data)
    } catch {}
  }
}
