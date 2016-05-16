# react-native-calendar-events
React Native EventKit wrapper for iOS

# Usage

```
import { NativeModules } from 'react-native'
```

### Init
This is optional. It is recommended by iOS documentation to init the events database once and use it throughout the app's lifetime since it is a time consuming op. Put this call where appropriate to kick off the EventKit database init.
```
NativeModules.ReactNativeCalendarEvents.initEventsDatabase()
```

### Request for iOS Permissions
```
NativeModules.ReactNativeCalendarEvents.requestAccess((error, status) => {
  console.log("Status returned: ", status)  // true | false
  console.log("Error returned: ", error)    // nil of status == true
})
```

### Getting Events
```
NativeModules.ReactNativeCalendarEvents.getEvents(0)
  .then(events => {
    console.log(">>>>>> EVENTS", events)
  })
  .catch(error => {
    console.log("Something went wrong retrieving events.")
  })
```
