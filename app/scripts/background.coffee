'use strict';

chrome.runtime.onInstalled.addListener (details) ->
  console.log('previousVersion', details.previousVersion)

# chrome.browserAction.setBadgeText({text: '+15'})

Stat =
  data: {}
  cur: null

tabChanged = (url) ->
  if Stat.cur == url
    lst = Stat.data[Stat.cur]
    lst.push(new Date())  
  else
    Stat.cur = url
    lst = Stat.data[url] or []
    lst.push(new Date())
    Stat.data[url] = lst

getHostName = (href) ->
    l = document.createElement('a')
    l.href = href
    l

calc = (url)->
  lst = Stat.data[url]
  if not lst
    return 0
  if(lst.length >= 2)
    res = (new Date()).getTime() - lst[lst.length - 2].getTime()
    return res
  else
    return 0

secondsToHms = (d) ->
  d = Number(d)
  h = Math.floor(d / 3600)
  m = Math.floor(d % 3600 / 60)
  s = Math.floor(d % 3600 % 60)
  (if h > 0 then h + ':' + (if m < 10 then '0' else '') else '') + m + ':' + (if s < 10 then '0' else '') + s

updateBadge = (url)->
  local = localStorage["#{url}"]
  # console.log calc url
  if local
    res = (calc url)/1000 + (parseInt(localStorage["#{url}"]))
    loadToStorage url, res
    form = secondsToHms res
    chrome.browserAction.setBadgeText({text: "#{form}"})
  else
    res = (calc url)/1000
    loadToStorage url, res
    form = secondsToHms res
    chrome.browserAction.setBadgeText({text: "#{form}"})

  
loadToStorage = (url, res) ->
  localStorage["#{url}"] = res

chrome.tabs.onActivated.addListener (activeInfo) ->
  Stat.curTabId = activeInfo.tabId
  chrome.tabs.get activeInfo.tabId, (tab) ->
    host = getHostName(tab.url)
    if host.protocol == "http:" or host.protocol == "https:"
      if host.hostname
        tabChanged host.hostname
      updateBadge host.hostname
    
chrome.alarms.onAlarm.addListener (alarm) ->
  if alarm.name == 'update'
    if !Stat.curTabId
      return
    return chrome.tabs.get(Stat.curTabId, (tab) ->
      host = getHostName(tab.url)
      if host.protocol == "http:" or host.protocol == "https:"
        tabChanged host.hostname
      updateBadge host.hostname
    )
  return

chrome.alarms.create("update", {periodInMinutes: 0.1})
console.log('\'Allo \'Allo! Event Page for Browser Action')
