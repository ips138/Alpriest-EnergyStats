//
//  NetworkCache.swift
//  Energy Stats Core
//
//  Created by Alistair Priest on 12/09/2023.
//

import Foundation

struct CachedItem {
    let cacheTime: Date
    let item: Codable

    init(_ item: Codable) {
        self.cacheTime = Date()
        self.item = item
    }

    func isFresherThan(interval: TimeInterval) -> Bool {
        abs(cacheTime.timeIntervalSinceNow) < interval
    }
}

public class NetworkCache: FoxESSNetworking {
    private let network: FoxESSNetworking
    private var cache: [String: CachedItem] = [:]
    private let shortCacheDurationInSeconds: TimeInterval = 5
    private let serialiserQueue = DispatchQueue(label: "networkcache.write.queue")

    public init(network: FoxESSNetworking) {
        self.network = network
    }

    public func deleteScheduleTemplate(templateID: String) async throws {
        try await network.deleteScheduleTemplate(templateID: templateID)
    }

    public func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws {
        try await network.saveScheduleTemplate(deviceSN: deviceSN, template: template)
    }

    public func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse {
        try await network.fetchScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    }

    public func enableScheduleTemplate(deviceSN: String, templateID: String) async throws {
        try await network.enableScheduleTemplate(deviceSN: deviceSN, templateID: templateID)
    }

    public func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse {
        try await network.fetchScheduleTemplates()
    }

    public func createScheduleTemplate(name: String, description: String) async throws {
        try await network.createScheduleTemplate(name: name, description: description)
    }

    public func deleteSchedule(deviceSN: String) async throws {
        try await network.deleteSchedule(deviceSN: deviceSN)
    }

    public func saveSchedule(deviceSN: String, schedule: Schedule) async throws {
        try await network.saveSchedule(deviceSN: deviceSN, schedule: schedule)
    }

    public func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse {
        try await network.fetchCurrentSchedule(deviceSN: deviceSN)
    }

    public func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse] {
        try await network.fetchScheduleModes(deviceID: deviceID)
    }

    public func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse {
        try await network.fetchSchedulerFlag(deviceSN: deviceSN)
    }

    public func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse] {
        try await network.fetchReport(deviceID: deviceID, variables: variables, queryDate: queryDate, reportType: reportType)
    }

    public func fetchBattery(deviceID: String) async throws -> BatteryResponse {
        let key = makeKey(base: "fetchBattery", arguments: deviceID)

        if let item = cache[key], let cached = item.item as? BatteryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.fetchBattery(deviceID: deviceID)

            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse {
        let key = makeKey(base: #function, arguments: deviceSN)

        if let item = cache[key], let cached = item.item as? BatterySettingsResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.openapi_fetchBatterySettings(deviceSN: deviceSN)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse] {
        try await network.fetchRaw(deviceID: deviceID, variables: variables, queryDate: queryDate)
    }

    public func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse] {
        let key = makeKey(base: #function)

        if let item = cache[key], let cached = item.item as? [DeviceDetailResponse], item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.openapi_fetchDeviceList()
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse {
        let key = makeKey(base: #function, arguments: deviceID)

        if let item = cache[key], let cached = item.item as? AddressBookResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.fetchAddressBook(deviceID: deviceID)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func fetchVariables(deviceID: String) async throws -> [RawVariable] {
        try await network.fetchVariables(deviceID: deviceID)
    }

    public func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws {
        try await network.openapi_setBatterySoc(deviceSN: deviceSN, minSOCOnGrid: minSOCOnGrid, minSOC: minSOC)
    }

    public func openapi_fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse {
        try await network.openapi_fetchBatteryTimes(deviceSN: deviceSN)
    }

    public func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws {
        try await network.setBatteryTimes(deviceSN: deviceSN, times: times)
    }

    public func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse {
        try await network.fetchWorkMode(deviceID: deviceID)
    }

    public func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws {
        try await network.setWorkMode(deviceID: deviceID, workMode: workMode)
    }

    public func fetchDataLoggers() async throws -> PagedDataLoggerListResponse {
        try await network.fetchDataLoggers()
    }

    public func fetchErrorMessages() async {
        await network.fetchErrorMessages()
    }

    public func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.joined(separator: "_"))

        if let item = cache[key], let cached = item.item as? OpenQueryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.openapi_fetchRealData(deviceSN: deviceSN, variables: variables)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse {
        let key = makeKey(base: #function, arguments: deviceSN, variables.joined(separator: "_"), String(start.timeIntervalSince1970), String(end.timeIntervalSince1970))

        if let item = cache[key], let cached = item.item as? OpenHistoryResponse, item.isFresherThan(interval: shortCacheDurationInSeconds) {
            print("AWP", "Return cached")
            return cached
        } else {
            print("AWP", "Fetch fresh")
            let fresh = try await network.openapi_fetchHistory(deviceSN: deviceSN, variables: variables, start: start, end: end)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }

    public func openapi_fetchVariables() async throws -> [OpenApiVariable] {
        try await network.openapi_fetchVariables()
    }

    public func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse] {
        let key = makeKey(base: #function, arguments: deviceSN, variables.map { $0.networkTitle }.joined(separator: "_"))

        if let item = cache[key], let cached = item.item as? [OpenReportResponse], item.isFresherThan(interval: shortCacheDurationInSeconds) {
            return cached
        } else {
            let fresh = try await network.openapi_fetchReport(deviceSN: deviceSN, variables: variables, queryDate: queryDate, reportType: reportType)
            store(key: key, value: CachedItem(fresh))
            return fresh
        }
    }
}

private extension NetworkCache {
    func makeKey(base: String, arguments: String?...) -> String {
        ([base] + arguments.compactMap { $0 }).joined(separator: "_")
    }

    private func store(key: String, value: CachedItem) {
        serialiserQueue.sync {
            cache[key] = value
        }
    }
}
