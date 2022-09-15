package dbdata

import (
	"encoding/json"

	"xorm.io/xorm"
)

type SearchCon struct {
	Username    string   `json:"username"`
	Src         string   `json:"src"`
	Dst         string   `json:"dst"`
	DstPort     string   `json:"dst_port"`
	AccessProto string   `json:"access_proto"`
	Date        []string `json:"date"`
	Info        string   `json:"info"`
}

func GetAuditSession(search string) *xorm.Session {
	session := xdb.Where("1=1")
	if search == "" {
		return session
	}
	var searchData SearchCon
	err := json.Unmarshal([]byte(search), &searchData)
	if err != nil {
		return session
	}
	if searchData.Username != "" {
		session.And("username = ?", searchData.Username)
	}
	if searchData.Src != "" {
		session.And("src = ?", searchData.Src)
	}
	if searchData.Dst != "" {
		session.And("dst = ?", searchData.Dst)
	}
	if searchData.DstPort != "" {
		session.And("dst_port = ?", searchData.DstPort)
	}
	if searchData.AccessProto != "" {
		session.And("access_proto = ?", searchData.AccessProto)
	}
	if len(searchData.Date) > 0 && searchData.Date[0] != "" {
		session.And("created_at BETWEEN ? AND ?", searchData.Date[0], searchData.Date[1])
	}
	if searchData.Info != "" {
		session.And("info LIKE ?", "%"+searchData.Info+"%")
	}
	return session
}