import Foundation
import AVFoundation

class QuranDownloadManager: ObservableObject {
    static let shared = QuranDownloadManager()
    
    @Published var downloadedSurahs: Set<Int> = []
    @Published var currentDownloadProgress: [Int: Double] = [:]
    @Published var isDownloading = false
    
    private let fileManager = FileManager.default
    private var downloadTasks: [Int: URLSessionDownloadTask] = [:]
    private let downloadQueue = DispatchQueue(label: "com.iammuslim.download", qos: .utility)
    
    private init() {
        loadDownloadedSurahs()
    }
    
    private var downloadDirectory: URL? {
        fileManager.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("QuranAudio")
    }
    
    private func loadDownloadedSurahs() {
        guard let directory = downloadDirectory else { return }
        
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            downloadedSurahs = Set(files.compactMap { url -> Int? in
                let filename = url.deletingPathExtension().lastPathComponent
                return Int(filename)
            })
        } catch {
            print("Error loading downloaded surahs: \(error)")
        }
    }
    
    func downloadSurah(_ surah: QuranSurah) {
        guard let url = URL(string: "https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/\(surah.number).mp3"),
              let directory = downloadDirectory else { return }
        
        let destination = directory.appendingPathComponent("\(surah.number).mp3")
        
        // Check if already downloaded or being downloaded
        if fileManager.fileExists(atPath: destination.path) {
            downloadedSurahs.insert(surah.number)
            return
        }
        
        if downloadTasks[surah.number] != nil {
            return // Already downloading
        }
        
        isDownloading = true
        currentDownloadProgress[surah.number] = 0.0
        
        let session = URLSession(configuration: .default)
        let task = session.downloadTask(with: url) { [weak self] tempURL, response, error in
            guard let self = self else { return }
            
            self.downloadQueue.async {
                defer {
                    DispatchQueue.main.async {
                        self.downloadTasks.removeValue(forKey: surah.number)
                        if self.downloadTasks.isEmpty {
                            self.isDownloading = false
                        }
                        self.currentDownloadProgress.removeValue(forKey: surah.number)
                    }
                }
                
                guard let tempURL = tempURL,
                      error == nil else {
                    print("Download error: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                do {
                    try self.fileManager.moveItem(at: tempURL, to: destination)
                    DispatchQueue.main.async {
                        self.downloadedSurahs.insert(surah.number)
                    }
                } catch {
                    print("Error saving downloaded file: \(error)")
                }
            }
        }
        
        downloadTasks[surah.number] = task
        task.resume()
    }
    
    func cancelDownload() {
        downloadTasks.values.forEach { $0.cancel() }
        downloadTasks.removeAll()
        isDownloading = false
        currentDownloadProgress.removeAll()
    }
    
    func deleteSurah(_ surahNumber: Int) {
        guard let directory = downloadDirectory else { return }
        let fileURL = directory.appendingPathComponent("\(surahNumber).mp3")
        
        do {
            try fileManager.removeItem(at: fileURL)
            downloadedSurahs.remove(surahNumber)
        } catch {
            print("Error deleting surah: \(error)")
        }
    }
    
    func deleteAllDownloads() {
        guard let directory = downloadDirectory else { return }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            try files.forEach { try fileManager.removeItem(at: $0) }
            downloadedSurahs.removeAll()
        } catch {
            print("Error deleting all downloads: \(error)")
        }
    }
    
    func getLocalFileURL(for surahNumber: Int) -> URL? {
        guard let directory = downloadDirectory else { return nil }
        let fileURL = directory.appendingPathComponent("\(surahNumber).mp3")
        return fileManager.fileExists(atPath: fileURL.path) ? fileURL : nil
    }
    
    func getDownloadedSize() -> Int64 {
        guard let directory = downloadDirectory else { return 0 }
        
        do {
            let files = try fileManager.contentsOfDirectory(at: directory, includingPropertiesForKeys: [.fileSizeKey])
            return files.reduce(0) { total, url in
                guard let size = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else { return total }
                return total + Int64(size)
            }
        } catch {
            print("Error calculating download size: \(error)")
            return 0
        }
    }
}
