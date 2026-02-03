package utils

import "time"

func IsSameDay(fromTime, toTime time.Time) bool {
	diff := int(toTime.Sub(fromTime).Hours() / 24)
	if diff == 0 {
		return true
	}
	return false
}
