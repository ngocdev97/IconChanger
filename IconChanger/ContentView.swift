import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @State private var selectedFile: URL? = nil
    @State private var showingFilePicker = false
    @State private var destinationFolder: URL? = nil
    @State private var showingFolderPicker = false
    @State private var errorMessage: String? = nil
    @State private var successMessage: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Upload and Export Image")
                .font(.title)
            
            if let selectedFile = selectedFile {
                Text("Selected file: \(selectedFile.lastPathComponent)")
            } else {
                VStack {
                    Text("Drag and Drop file here or")
                    Button(action: {
                        showingFilePicker = true
                    }) {
                        Text("Choose file")
                            .foregroundColor(.blue)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: 200)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .padding()
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            if let successMessage = successMessage {
                Text(successMessage)
                    .foregroundColor(.green)
                    .padding()
            }
            
            Button(action: {
                showingFolderPicker = true
            }) {
                Text("Select Destination Folder")
                    .foregroundColor(.blue)
            }
            .padding()
            .disabled(selectedFile == nil)
            
            Button(action: {
                if let selectedFile = selectedFile,
                   let destinationFolder = destinationFolder {
                    processImage(fileURL: selectedFile, destinationFolder: destinationFolder)
                }
            }) {
                Text("Export Images")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
            .disabled(selectedFile == nil || destinationFolder == nil)
            
            Spacer()
            
            HStack {
                Button("Cancel") {
                    // Handle cancel action
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button(action: {
                    // Handle download example action
                }) {
                    Text("Download")
                }
            }
            .padding()
        }
        .padding()
        .fileImporter(isPresented: $showingFilePicker, allowedContentTypes: [.image], allowsMultipleSelection: false) { result in
            do {
                guard let selectedFileURL = try result.get().first else { return }
                validateImage(url: selectedFileURL)
            } catch {
                errorMessage = "Failed to select file: \(error.localizedDescription)"
            }
        }
    }
    
    private func validateImage(url: URL) {
        guard let image = NSImage(contentsOf: url) else {
            errorMessage = "The selected file is not a valid image."
            selectedFile = nil
            return
        }
        
        let imageSize = image.size
        if imageSize.width != imageSize.height {
            errorMessage = "The image must have a 1:1 aspect ratio."
            selectedFile = nil
            return
        }
        
        if imageSize.width > 500 || imageSize.height > 500 {
            errorMessage = "The image must be under 500px in size."
            selectedFile = nil
            return
        }
        
        selectedFile = url
        errorMessage = nil
    }
    
    private func processImage(fileURL: URL, destinationFolder: URL) {
        guard let image = NSImage(contentsOf: fileURL) else {
            errorMessage = "Failed to load the image."
            return
        }
        
        exportImages(image: image, baseName: "finder", destinationFolder: destinationFolder)
        successMessage = "Images have been successfully exported."
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
