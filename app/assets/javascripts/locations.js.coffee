# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

addCommas = (nStr) ->
  nStr += ""
  x = nStr.split(".")
  x1 = x[0]
  x2 = (if x.length > 1 then "." + x[1] else "")
  rgx = /(\d+)(\d{3})/
  x1 = x1.replace(rgx, "$1" + "," + "$2")  while rgx.test(x1)
  x1 + x2

$(() ->
  console.log(gon.id)
  $.get("http://kawal-pemilu.appspot.com/api/children/" + gon.id,
    (data) ->
      console.log(data)
      $(".c1_prabowo").each((index) ->
        $(this).html(addCommas(data[index][2]))
      )
      $(".c1_jokowi").each((index) ->
        $(this).html(addCommas(data[index][3]))
      )
  )
)