//
//  ContentView.swift
//  balinasoft
//
//  Created by Artem Shuneyko on 3.05.23.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel = ListViewModel()
    @State private var selectedItem: ListItem? = nil
    
    private let sourceType: UIImagePickerController.SourceType = .camera
    @State private var photo: UIImage?
    @State private var selectedId: Int?
    @State private var isImagePickerDisplay = false
    
    var body: some View {
        List(viewModel.items) { item in
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                
                if let image = item.image {
                    AsyncImage(url: URL(string: image)) { phase in
                        if let image = phase.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else if phase.error != nil {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } else {
                            HStack {
                                Spacer()
                                ProgressView("Loading...")
                                Spacer()
                            }
                        }
                    }
                }
                else{
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .onAppear {
                if item.id == viewModel.items.last?.id {
                    viewModel.fetchItems()
                }
            }
            .onTapGesture {
                selectedId = item.id
                isImagePickerDisplay.toggle()
            }
        }
        .onAppear {
            viewModel.fetchItems()
        }
        .sheet(isPresented: $isImagePickerDisplay) {
            ZStack{
                Color.black.edgesIgnoringSafeArea(.all)
                ImagePickerView(selectedImage: $photo, sourceType: sourceType)
                    .onAppear {
                        UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                        AppDelegate.orientationLock = .portrait
                    }.onDisappear {
                        AppDelegate.orientationLock = .all
                    }
            }
        }
        .onChange(of: photo) { newPhotoValue in
            guard let newPhoto = newPhotoValue, let selectedId = selectedId else { return }
            viewModel.sendPhoto(id: selectedId, image: newPhoto)
            self.selectedId = nil
            self.photo = nil
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
