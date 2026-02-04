package utils

import (
	"strings"
	"time"
)

const TimeLayout = "2006-01-02T15:04:05.000Z"
const TimeLayout_Default = "2006-01-02 15:04:05.999999999 -0700 MST"

func ToISOString(t time.Time) string {
	return t.UTC().Format(TimeLayout)
}

func Parse(s string) (t time.Time, err error) {
	return time.Parse(TimeLayout, s)
}

func FromIsoString(s string) int64 {
	t, err := time.Parse(TimeLayout, s)
	if err != nil {
		return 0
	}
	return t.Unix()
}
func ToUnix(i int64) (tm time.Time) {
	tm = time.Unix(i, 0)
	return
}
func CurrentTimeStampSecond() int64 {
	return time.Now().Unix()
}

func CurrentDate() string {
	var weekDay = time.Now().UTC().Weekday()
	return strings.ToLower(weekDay.String())
}

func NextDayAtHour(hour int) int64 {
	now := time.Now()
	tomorrow := time.Date(now.Year(), now.Month(), now.Day()+1, hour, 0, 0, 0, time.UTC)
	return tomorrow.Unix()
}

func NextWeekAtHour(hour int) int64 {
	now := time.Now()
	iWeekDay := int(now.Weekday())
	remainInWeek := 7 - iWeekDay
	nextWeekAtHour := time.Date(now.Year(), now.Month(), now.Day()+remainInWeek+1, hour, 0, 0, 0, time.UTC)
	return nextWeekAtHour.Unix()
}
func CurrentVietnameseTime() time.Time {
	loc := time.FixedZone("Asia/Ho_Chi_Minh", 7*60*60)
	return time.Now().In(loc)
}

func StartOfVietnameseDay() time.Time {
	loc := time.FixedZone("Asia/Ho_Chi_Minh", 7*60*60)
	t := time.Now().In(loc)
	return time.Date(t.Year(), t.Month(), t.Day(), 0, 0, 0, 0, loc)
}

func EndOfVietnameseDay() time.Time {
	loc := time.FixedZone("Asia/Ho_Chi_Minh", 7*60*60)
	t := time.Now().In(loc)
	return time.Date(t.Year(), t.Month(), t.Day(), 23, 59, 59, 99, loc)
}

// IsSameDay returns true if fromTime and toTime are on the same calendar day.
func IsSameDay(fromTime, toTime time.Time) bool {
	return fromTime.Year() == toTime.Year() && fromTime.YearDay() == toTime.YearDay()
}
