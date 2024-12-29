//
//  ImportFileManager.swift
//  Player
//
//  Created by Муртазали Магомедов on 05.10.2024.
//

import Foundation
import SwiftUI
import AVFoundation
import RealmSwift

/// Позволяет выбрать аудиофайл и импортировать его в приложение
struct ImportFileManager: UIViewControllerRepresentable {
    
    /// Координатор управляет задачами между SWiftUI и UIKit
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    /// Метод, который создаёт и настраивает UIDocumentPickerViewController, который используется для выбора аудиофайлов
    func makeUIViewController(context: Context) -> some UIDocumentPickerViewController {
        /// Разрешение открытия файлов с типом "public.audio"(.MP3, WAV)
        let picker = UIDocumentPickerViewController(documentTypes: ["public.audio"], in: .open)
        /// Запрет выбора множества файлов
        picker.allowsMultipleSelection = false
        ///  Показ разрешения файлов
        picker.shouldShowFileExtensions = true
        /// Установка координатора в качестве делегата
        picker.delegate = context.coordinator
        return picker
    }
    
    /// Метод предназначен для обновления контроллера с новыми данными. В данном случае он пуст, т.к. все необходимые настройки будут выполнены при создании
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    /// служит связующим звеном между UIDocementPicker и ImportFileManager
    final class Coordinator: NSObject, UIDocumentPickerDelegate {
        
        /// Ссылка на родительский класс, чтобы можно было с ним взаимодействовать
        var parent: ImportFileManager
        @ObservedResults(SongModel.self) var songs
        
        init(parent: ImportFileManager) {
            self.parent = parent
        }
        
        /// Метод вызывается, когда пользователь выбирает аудиофайл
        /// Метод обрабатывает выбранный URL и создаёт аудиофайл с типом SongModel и после добавляет файл в массив  song
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            /// Безопасно извлекается первый элемент из массива urls. Если массив пуст, то urls.first вернёт nil и условие не пропустит дальше, что приведёт к выходу из метода
            /// После успешного извлекания url, метод startAccessingSecurityScopedResource вызывается для выдачи доступа к защищённому ресурсу
            guard let url = urls.first, url.startAccessingSecurityScopedResource() else {return}
            
            /// Гарантирует, что метод stopAccessingSecurityScopedResource будет вызван, когда выполнение docementPicker завершится, вне зависимости успешно или нет.
            /// Ресурс безопасности будет закрыт и освобождён из памяти
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                /// Получение данных файла
                let document = try Data(contentsOf: url)
                
                /// Создание AVAsset для извлечения метаданных
                let asset = AVAsset(url: url)
                
                /// Инициализируем объект SongModel
                var song = SongModel(name: url.lastPathComponent, data: document)
                
                /// Цикл для итерации по метаданным аудиофайла, чтобы извлечь данные(исполнитель, обложка, название)
                let metadata = asset.metadata
                for item in metadata {
                    /// Проверяем есть ли метаданные у файла через ключ-значение
                    guard let key = item.commonKey?.rawValue, let value = item.value else {continue}
                    switch key {
                    case AVMetadataKey.commonKeyArtist.rawValue:
                        song.artist = value as? String
                    case AVMetadataKey.commonKeyArtwork.rawValue:
                        song.coverImage = value as? Data
                    case AVMetadataKey.commonKeyTitle.rawValue:
                        song.name = value as? String ?? song.name
                    default:
                        break
                    }
                }
                
                /// Получение продолжительности песни
                song.duration = CMTimeGetSeconds(asset.duration)
                
                let isDublicates = songs.contains { $0.name == song.name && $0.artist == song.artist}
                /// Добавление аудиофайла в массив, если его там не имеется
                if !isDublicates {
                    DispatchQueue.main.async {
                        self.$songs.append(song)
                    }
                } else {
                    print("Song with same name alredy exists")
                }
            }
            catch {
                print("Error processing the file: \(error)")
            }
        }
    }
}
