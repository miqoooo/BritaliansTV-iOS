//
//  MainPage.swift
//  BritaliansTV
//
//  Created by miqo on 07.11.23.
//

import SwiftUI
import XMLCoder

class MainPageVM: ObservableObject {
    private let api = DataFetcher.shared
    private var taskList: [String: Task<Void, Never>?] = [:]
    
    @Published var loading: Bool = true
    @Published var tabSelection: TabItem = .home
    @Published var updateAdData: Bool = false
    
    var adData: AdModel? = nil
    var adTimer: Timer? = nil
    
    var data: ChannelModel? = nil
    var allItems: [ItemModel] = []
    
    var rowData: [String: [RowModel]] = [:]
    
    func onTabSelection(selection: TabItem) {
        self.loading = true

        for task in taskList {
            print("Cancelling task: ", task.key)
            task.value?.cancel()
        }
        self.taskList = [:]
        
        executeTask(taskIdPrefix: selection.name) {
            switch selection {
            case .home:
                try await self.loadHomeData()
                
            case .states:
                try await self.loadContent(title: "States", endpoint: .STATES)
                
            case .humans:
                try await self.loadContent(title: "Humans", endpoint: .HUMANS)
                
            case .brands:
                try await self.loadContent(title: "Brands", endpoint: .BRANDS)
                
            default:
                break
            }
        }
    }
    
    func loadData() async {
        do {
            await fetchAdData()
            try await self.loadHomeData()
            
            DispatchQueue.main.async {
                self.adTimer = Timer.scheduledTimer(withTimeInterval: Double(self.adData!.ad_interval ?? 1) * 60, repeats: true) { _ in
                    Task { await self.fetchAdData() }
                }
            }
        } catch {
            print("[ERROR]: [", error, "]")
        }
    }
    
    private func loadHomeData() async throws {
        if Task.isCancelled { return }
        
        //let rssData: RssModel = try await api.GET(endpoint: .CONTENT)
        let path = Bundle.main.path(forResource: "uniquerss", ofType: "rss")!
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let rssData = try XMLDecoder().decode(RssModel.self, from: data)
        
        print("[SUCCESS loadMainPageData: ", rssData.channel.rows.count, "]")
        
        if Task.isCancelled { return }
        DispatchQueue.main.async {
            self.data = rssData.channel
            self.allItems = rssData.channel.rows.flatMap({ $0.items })
            
            self.rowData[TabItem.home.name] = rssData.channel.rows
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { @MainActor in
                self.loading = false
            })
        }
    }
    
    private func loadContent(title: String, endpoint: Endpoint) async throws {
        if Task.isCancelled { return }
        
        let rssData: RSSFeedModel = try await api.GET(endpoint: endpoint)
        print("[SUCCESS loadStates: ", rssData.rows.count, "]")
        
        //let itemList = rssData.rows.compactMap({ ItemModel.init(rowItemModel: $0) })
        var rowItemList: [ItemModel] = []
        
        for rowItem in rssData.rows {
            let items = self.allItems.filter({ $0.videoRow.contains(where: { $0.items.contains(where: { $0.title == rowItem.details_name }) }) })
            let season = SeasonModel(title: rowItem.details_name, id: UUID().hashValue, items: items)
            
            var item = ItemModel(rowItemModel: rowItem)
            item.CK_content = "list"
            item.CK_series = SeriesModel(season: [season])
            rowItemList.append(item)
        }
        
        let rowData = RowModel(title: title, items: rowItemList)
        
        if Task.isCancelled { return }
        DispatchQueue.main.async {
            self.rowData[title] = [rowData]
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { @MainActor in
                self.loading = false
            })
        }
    }
    
    private func fetchAdData() async {
        do {
            let adData: AdModel = try await api.GET(endpoint: .BTV_ADS, host: URL(string: "https://britalians.tv/")!)
            self.adData = adData
            
            DispatchQueue.main.async { @MainActor in
                self.updateAdData.toggle()
            }
        } catch {
            print("[ERROR]: [", error, "]")
        }
    }
    
    private func executeTask(taskIdPrefix: String = "", _ function: @escaping () async throws -> Void) {
        let taskId = taskIdPrefix + "_" + UUID().uuidString
        
        let task = Task {
            do {
                try await function()
            } catch {
                print("[ERROR]: [", error, "]")
            }
            
            taskList.removeValue(forKey: taskId)
        }
        
        self.taskList[taskId] = task
    }
}
