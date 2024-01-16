//
//  Networking.swift
//  Energy Stats
//
//  Created by Alistair Priest on 06/09/2022.
//

import Foundation

extension URL {
    static var report = URL(string: "https://www.foxesscloud.com/c/v0/device/history/report")!
    static var raw = URL(string: "https://www.foxesscloud.com/c/v0/device/history/raw")!
    static var battery = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/info")!
    static var addressBook = URL(string: "https://www.foxesscloud.com/c/v0/device/addressbook")!
    static var variables = URL(string: "https://www.foxesscloud.com/c/v1/device/variables")!
    static var deviceSettings = URL(string: "https://www.foxesscloud.com/c/v0/device/setting/get")!
    static var deviceSettingsSet = URL(string: "https://www.foxesscloud.com/c/v0/device/setting/set")!
    static var moduleList = URL(string: "https://www.foxesscloud.com/c/v0/module/list")!
    static var errorMessages = URL(string: "https://www.foxesscloud.com/c/v0/errors/message")!
    static var batteryTimeSet = URL(string: "https://www.foxesscloud.com/c/v0/device/battery/time/set")!
}

public protocol FoxESSNetworking {
    @available(*, deprecated, renamed: "openapi_fetchReport", message: "Unavailable")
    func fetchReport(deviceID: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [ReportResponse]
    @available(*, deprecated, renamed: "openapi_fetchRealData", message: "Unavailable")
    func fetchRaw(deviceID: String, variables: [RawVariable], queryDate: QueryDate) async throws -> [RawResponse]

    func fetchBattery(deviceID: String) async throws -> BatteryResponse
    func fetchAddressBook(deviceID: String) async throws -> AddressBookResponse
    func fetchVariables(deviceID: String) async throws -> [RawVariable]
    func fetchWorkMode(deviceID: String) async throws -> DeviceSettingsGetResponse
    func setWorkMode(deviceID: String, workMode: InverterWorkMode) async throws
    func fetchDataLoggers() async throws -> PagedDataLoggerListResponse
    func fetchErrorMessages() async

    func fetchSchedulerFlag(deviceSN: String) async throws -> SchedulerFlagResponse
    func fetchScheduleModes(deviceID: String) async throws -> [SchedulerModeResponse]
    func fetchCurrentSchedule(deviceSN: String) async throws -> ScheduleListResponse
    func saveSchedule(deviceSN: String, schedule: Schedule) async throws
    func saveScheduleTemplate(deviceSN: String, template: ScheduleTemplate) async throws
    func deleteSchedule(deviceSN: String) async throws
    func createScheduleTemplate(name: String, description: String) async throws
    func fetchScheduleTemplates() async throws -> ScheduleTemplateListResponse
    func enableScheduleTemplate(deviceSN: String, templateID: String) async throws
    func fetchScheduleTemplate(deviceSN: String, templateID: String) async throws -> ScheduleTemplateResponse
    func deleteScheduleTemplate(templateID: String) async throws

    func openapi_fetchDeviceList() async throws -> [DeviceDetailResponse]
    func openapi_fetchRealData(deviceSN: String, variables: [String]) async throws -> OpenQueryResponse
    func openapi_fetchHistory(deviceSN: String, variables: [String], start: Date, end: Date) async throws -> OpenHistoryResponse
    func openapi_fetchVariables() async throws -> [OpenApiVariable]
    func openapi_fetchReport(deviceSN: String, variables: [ReportVariable], queryDate: QueryDate, reportType: ReportType) async throws -> [OpenReportResponse]
    func openapi_fetchBatterySettings(deviceSN: String) async throws -> BatterySettingsResponse
    func openapi_setBatterySoc(deviceSN: String, minSOCOnGrid: Int, minSOC: Int) async throws
    func openapi_fetchBatteryTimes(deviceSN: String) async throws -> BatteryTimesResponse
    func setBatteryTimes(deviceSN: String, times: [ChargeTime]) async throws
}
