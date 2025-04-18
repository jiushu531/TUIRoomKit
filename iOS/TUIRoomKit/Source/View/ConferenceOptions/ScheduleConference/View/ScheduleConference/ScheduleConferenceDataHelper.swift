//
//  ScheduleConferenceDataHelper.swift
//  TUIRoomKit
//
//  Created by janejntang on 2024/6/19.
//

import Foundation
import RTCRoomEngine
import Factory

class ScheduleConferenceDataHelper {
    open class func generateScheduleConferenceData(route: Route,
                                                   store: ScheduleConferenceStore,
                                                   operation: ConferenceStore,
                                                   viewController: ContactViewSelectDelegate? = nil) -> [Int: [CellConfigItem]] {
        var menus: [Int:[CellConfigItem]] = [:]
        menus[0] = getFirstSectionMenus(route: route, store: store, viewController: viewController)
        menus[1] = getSecondSectionMenus(route: route, store: store)
        menus[2] = getThirdSectionMenus(route: route, store: store)
        menus[3] = getFourthSectionMenus(route: route, store: store, operation: operation)
        return menus
    }
}

// MARK: - private function.
extension ScheduleConferenceDataHelper {
    
    class func getFirstSectionMenus(route: Route, store: ScheduleConferenceStore, viewController: ContactViewSelectDelegate?) -> [CellConfigItem] {
        var array: [CellConfigItem] = []
        array.append(getConferenceNameItem(route: route, store: store))
        array.append(getConferenceTypeItem(route: route, store: store))
        array.append(getStartTimeItem(route: route, store: store))
        array.append(getDurationTimeItem(route: route, store: store))
        array.append(getTimeZoneItem(route: route, store: store))
        if let participatingMembersItem = getParticipatingMembersItem(route: route, store: store, viewController: viewController) {
            array.append(participatingMembersItem)
        }
        return array
    }
    
    class func getSecondSectionMenus(route: Route, store: ScheduleConferenceStore) -> [CellConfigItem] {
        var array: [CellConfigItem] = []
        array.append(getEncryptRoomItem(store: store))
        if store.conferenceInfo.basicInfo.isPasswordEnabled {
            array.append(getRoomPasswordItem(store: store))
        }
        return array
    }
    
    class func getThirdSectionMenus(route: Route, store: ScheduleConferenceStore) -> [CellConfigItem] {
        var array: [CellConfigItem] = []
        array.append(getMuteAllItem(route: route, store: store))
        array.append(getFreezeVideoItem(route: route, store: store))
        return array
    }
    
    class func getFourthSectionMenus(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> [CellConfigItem] {
        return [getbookItem(route: route, store: store, operation: operation)]
    }
    
    class func getConferenceNameItem(route: Route, store: ScheduleConferenceStore) -> TextFieldItem{
        var conferenceNameItem = TextFieldItem(title: .roomNameText, content: store.conferenceInfo.basicInfo.name)
        conferenceNameItem.saveTextClosure = { text in
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.basicInfo.name = text
            store.update(conference: conferenceInfo)
        }
        conferenceNameItem.bindStateClosure = { cell, cancellableSet in
            let getBasicInfo = Selector(keyPath: \ConferenceInfo.basicInfo)
            let selector = Selector.with(getBasicInfo, keyPath: \RoomInfo.name)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] text in
                    if let cell = cell as? TextFieldCell {
                        cell.textField.text = text
                    }
                }
                .store(in: &cancellableSet)
        }
        return conferenceNameItem
    }
    
    class func getConferenceTypeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        let enableSeatControl = store.conferenceInfo.basicInfo.isSeatEnabled
        var conferenceTypeItem = ListItem(title: .roomTypeText, content: enableSeatControl ? .onStageSpeechRoomText: .freeSpeechRoomText)
        conferenceTypeItem.showButton = true
        conferenceTypeItem.selectClosure = {
            let view = RoomTypeView()
            view.dismissAction = {
                route.dismiss(animated: true)
            }
            route.present(route: .popup(view: view))
        }
        conferenceTypeItem.bindStateClosure = { cell, cancellableSet in
            let getBasicInfo = Selector(keyPath: \ConferenceInfo.basicInfo)
            let selector  = Selector.with(getBasicInfo, keyPath: \RoomInfo.isSeatEnabled)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] enableSeatControl in
                    if let cell = cell as? ScheduleTabCell {
                        cell.messageLabel.text = enableSeatControl ? .onStageSpeechRoomText: .freeSpeechRoomText
                    }
                }
                .store(in: &cancellableSet)
        }
        return conferenceTypeItem
    }
    
    class func getStartTimeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        let startTime = TimeInterval(store.conferenceInfo.scheduleStartTime)
        var startTimeItem = ListItem(title: .startingTimeText, content: getTimeIntervalString(startTime, timeZone: store.conferenceInfo.timeZone))
        startTimeItem.showButton = true
        startTimeItem.selectClosure = {
            let view = TimePickerView()
            view.pickerDate = Date(timeIntervalSince1970: TimeInterval(store.conferenceInfo.scheduleStartTime))
            view.dismissAction = {
                route.dismiss(animated: true)
            }
            route.present(route: .popup(view: view))
        }
        startTimeItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.scheduleStartTime)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] startTime in
                    if let cell = cell as? ScheduleTabCell {
                        cell.messageLabel.text = getTimeIntervalString(TimeInterval(startTime), timeZone: store.conferenceInfo.timeZone)
                    }
                }
                .store(in: &cancellableSet)
        }
        return startTimeItem
    }
    
    class func getDurationTimeItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var durationTimeItem = ListItem(title: .roomDurationText, content: getDurationTimeString(store.conferenceInfo.durationTime))
        durationTimeItem.showButton = true
        durationTimeItem.selectClosure = {
            let view = DurationPickerView()
            view.dismissAction = {
                route.dismiss(animated: true)
            }
            route.present(route: .popup(view: view))
        }
        durationTimeItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.durationTime)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] durationTime in
                    if let cell = cell as? ScheduleTabCell {
                        cell.messageLabel.text = getDurationTimeString(durationTime)
                    }
                }
                .store(in: &cancellableSet)
        }
        return durationTimeItem
    }
    
    class func getTimeZoneItem(route: Route, store: ScheduleConferenceStore) -> ListItem {
        var timeZoneItem = ListItem(title: .rimeZoneText, content: store.conferenceInfo.timeZone.getTimeZoneName())
        timeZoneItem.showButton = true
        timeZoneItem.buttonIcon = "room_right_arrow1"
        timeZoneItem.selectClosure = {
            route.pushTo(route: .timeZone)
        }
        timeZoneItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.timeZone)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] timeZone in
                    if let cell = cell as? ScheduleTabCell {
                        cell.messageLabel.text = timeZone.getTimeZoneName()
                    }
                }
                .store(in: &cancellableSet)
        }
        return timeZoneItem
    }
    
    class func getParticipatingMembersItem(route: Route, store: ScheduleConferenceStore, viewController: ContactViewSelectDelegate? = nil) -> ListItem? {
        var participatingMembersItem = ListItem(title: .participatingMembersText)
        participatingMembersItem.showButton = true
        participatingMembersItem.buttonIcon = "room_right_arrow1"
        participatingMembersItem.selectClosure = { [weak viewController] in
            guard let vc = viewController else { return }
            let users = store.conferenceInfo.attendeeListResult.attendeeList.map { $0.convertToUser() }
            let participants = ConferenceParticipants(selectedList: users)
            route.showContactView(delegate: vc, participants: participants)
        }
        participatingMembersItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.attendeeListResult.attendeeList)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] list in
                    if let cell = cell as? ScheduleTabCell {
                        var iconList: [String] = []
                        for i in 0...2 {
                            if let userInfo = list[safe: i] {
                                let avatarUrl = userInfo.avatarUrl.count > 0 ? userInfo.avatarUrl : "room_default_avatar_rect"
                                iconList.append(avatarUrl)
                            }
                        }
                        cell.updateStackView(iconList: iconList)
                        let totalCount = store.conferenceInfo.attendeeListResult.totalCount
                        cell.messageLabel.text = totalCount == 0 ? .addToText : localizedReplace(.participantsNumber, replace: String(totalCount))
                    }
                }
                .store(in: &cancellableSet)
        }
        return participatingMembersItem
    }
    
    class func getEncryptRoomItem(store: ScheduleConferenceStore) -> SwitchItem {
        var encryptRoomItem = SwitchItem(title: .encryptTheRoomText)
        encryptRoomItem.isOn = store.conferenceInfo.basicInfo.isPasswordEnabled
        encryptRoomItem.selectClosure = {
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.basicInfo.isPasswordEnabled = !store.conferenceInfo.basicInfo.isPasswordEnabled
            store.update(conference: conferenceInfo)
        }
        return encryptRoomItem
    }
    
    class func getRoomPasswordItem(store: ScheduleConferenceStore) -> TextFieldItem {
        var roomPasswordItem = TextFieldItem(title: .roomPasswordText, content: store.conferenceInfo.basicInfo.password)
        roomPasswordItem.keyboardType = .numberPad
        roomPasswordItem.maxLengthInBytes = 6
        roomPasswordItem.placeholder = .enterJoinRoomPassword
        roomPasswordItem.saveTextClosure = { text in
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.basicInfo.password = text
            store.update(conference: conferenceInfo)
        }
        return roomPasswordItem
    }
    
    class func getMuteAllItem(route: Route, store: ScheduleConferenceStore) -> SwitchItem {
        var muteAllItem = SwitchItem(title: .muteAllText)
        muteAllItem.isOn = store.conferenceInfo.basicInfo.isMicrophoneDisableForAllUser
        muteAllItem.selectClosure = {
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.basicInfo.isMicrophoneDisableForAllUser = !conferenceInfo.basicInfo.isMicrophoneDisableForAllUser
            store.update(conference: conferenceInfo)
        }
        muteAllItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.basicInfo.isMicrophoneDisableForAllUser)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] isMicrophoneDisableForAllUser in
                    if let cell = cell as? SwitchCell {
                        cell.rightSwitch.isOn = isMicrophoneDisableForAllUser
                    }
                }
                .store(in: &cancellableSet)
        }
        return muteAllItem
    }
    
    class func getFreezeVideoItem(route: Route, store: ScheduleConferenceStore) -> SwitchItem {
        var freezeVideoItem = SwitchItem(title: .freezeVideoText)
        freezeVideoItem.isOn = store.conferenceInfo.basicInfo.isCameraDisableForAllUser
        freezeVideoItem.selectClosure = {
            var conferenceInfo = store.conferenceInfo
            conferenceInfo.basicInfo.isCameraDisableForAllUser = !conferenceInfo.basicInfo.isCameraDisableForAllUser
            store.update(conference: conferenceInfo)
        }
        freezeVideoItem.bindStateClosure = { cell, cancellableSet in
            let selector = Selector(keyPath: \ConferenceInfo.basicInfo.isCameraDisableForAllUser)
            store.select(selector)
                .receive(on: RunLoop.main)
                .sink { [weak cell] isCameraDisableForAllUser in
                    if let cell = cell as? SwitchCell {
                        cell.rightSwitch.isOn = isCameraDisableForAllUser
                    }
                }
                .store(in: &cancellableSet)
        }
        return freezeVideoItem
    }
    
    class func getbookItem(route: Route, store: ScheduleConferenceStore, operation: ConferenceStore) -> ButtonItem {
        var bookItem = ButtonItem(title: .bookRoomText)
        bookItem.titleColor = UIColor(0xFFFFFF)
        bookItem.backgroudColor = UIColor(0x1C66E5)
        bookItem.selectClosure = {
            guard TimeInterval(store.conferenceInfo.scheduleStartTime) >= Date().timeIntervalSince1970 else {
                operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .startTimeCannotEarlierCurrentTime)))
                return
            }
            guard store.conferenceInfo.basicInfo.name.count > 0 else {
                operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .nameCannotBeEmptyText)))
                return
            }
            guard checkPasswordFormat(conferenceInfo: store.conferenceInfo) else {
                operation.dispatch(action: ViewActions.showToast(payload: ToastInfo(message: .passwordFormatIsIncorrect)))
                return
            }
            let conferenceInfo = TUIConferenceInfo(conferenceInfo: store.conferenceInfo)
            operation.dispatch(action: ConferenceListActions.scheduleConference(payload: conferenceInfo))
        }
        return bookItem
    }
    
    class func checkPasswordFormat(conferenceInfo: ConferenceInfo) -> Bool {
        if conferenceInfo.basicInfo.isPasswordEnabled {
            let password = conferenceInfo.basicInfo.password
            let passwordLength = 6
            return password.count == passwordLength && password.isStringOnlyDigits()
        } else {
            return true
        }
    }
    
    class func getTimeIntervalString(_ time: TimeInterval, timeZone: TimeZone) -> String {
        let date = Date(timeIntervalSince1970: time)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd HH:mm"
        dateFormatter.timeZone = timeZone
        return dateFormatter.string(from: date)
    }
    
    class func getDurationTimeString(_ time: UInt) -> String {
        guard time > 0 else { return "" }
        let hour = time / 3_600
        let minute = (time / 60) % 60
        var text = ""
        if hour > 0 {
            text = String(hour) + .hour
        }
        if minute > 0 {
            text = text + String(minute) + .minute
        }
        return text
    }
}

private extension String {
    static let roomNameText = localized("Room name")
    static let roomTypeText = localized("Room type")
    static let startingTimeText = localized("Starting time")
    static let roomDurationText = localized("Room duration")
    static let rimeZoneText = localized("Time zone")
    static let freeSpeechRoomText = localized("Free Speech Room")
    static let onStageSpeechRoomText = localized("On-stage Speech Room")
    static let muteAllText = localized("Mute All")
    static let freezeVideoText = localized("Freeze video")
    static let hour = localized("hour")
    static let minute = localized("minute")
    static let participatingMembersText = localized("Participating members")
    static let addToText = localized("Add to")
    static let encryptTheRoomText = localized("Encrypt the room")
    static let roomPasswordText = localized("Room Password")
    static let bookRoomText = localized("Schedule Room")
    static let nameCannotBeEmptyText = localized("Conference name cannot be empty!")
    static let participantsNumber = localized("xx/300 people")
    static let passwordFormatIsIncorrect = localized("Your room password format is incorrect, please check it")
    static let enterJoinRoomPassword = localized("Enter 6-digit password")
    static let startTimeCannotEarlierCurrentTime = localized("The start time cannot be earlier than the current time")
}
