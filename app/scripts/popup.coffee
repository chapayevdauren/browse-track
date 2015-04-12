'use strict';

console.log('\'Allo \'Allo! Popup')
console.log "clearStat"
localStorage.clear()

clearStat = ->
	console.log "clearStat"
	

doAmazingThings = ->
  	alert 'YOU AM AMAZING!'
  	return

document.addEventListener 'DOMContentReady', ->
  document.getElementById('amazing').addEventListener 'click', clearStat
  return

