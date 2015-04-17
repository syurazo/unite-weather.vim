"=============================================================================
" File    : autoload/unite/sources/weather/livedoor.vim
" Author  : syurazo <syurazo@gmail.com>
" License : MIT license
"=============================================================================

let s:save_cpo = &cpo
set cpo&vim

let s:area_url = 'http://weather.livedoor.com/forecast/rss/primary_area.xml'
let s:forecast_url = 'http://weather.livedoor.com/forecast/webservice/json/v1'

function! unite#sources#weather#livedoor#name_to_id(name)
  let dom = s:load_point_file()
  let point = dom.find('city', {"title": a:name})

  return (point != {} ? point.attr["id"] : '')
endfunction

function! unite#sources#weather#livedoor#get_point_list(area_condition)
  let dom = s:load_point_file()

  let areas = []
  if (strlen(a:area_condition) == 0)
    let areas = map(copy(dom.findAll('pref')), '{
    \   "id":    v:val.attr["title"],
    \   "name":  v:val.attr["title"],
    \   "level": "area",
    \ }')
  endif

  if (strlen(a:area_condition) > 0)
    let pref = dom.find('pref', {"title": a:area_condition})
    let elements = pref.findAll('city')
  else
    let elements = dom.findAll('city')
  endif
  let cities = map(copy(elements), '{
\   "id":    v:val.attr["id"],
\   "name":  v:val.attr["title"],
\   "level": "city",
\ }')

  return extend(areas, cities)
endfunction

function! unite#sources#weather#livedoor#get_forecast(id)
  let id = a:id
  if a:id !~ "^[0-9]*$"
    let id = unite#sources#weather#livedoor#name_to_id(a:id)
    if id == ''
      return {}
    endif
  endif
  let res = webapi#http#get(s:forecast_url, { "city": id })

  if res.status != '200'
    return {
\     'status':  res.status,
\     'message': res.message
\   }
  else
    let json = webapi#json#decode(res.content)

    return {
\     'status':     '200',
\     'message':    '',
\     'provider':   json.copyright.provider[0].name,
\     'publisher':  json.copyright.image.title,
\     'location':   json.location.city,
\     'published':  json.description.publicTime,
\     'title':      json.title,
\     'descripton': substitute(json.description.text,"\n","","g"),
\     'daily':  [
\       s:get_forecast_daily(json, 'today'),
\       s:get_forecast_daily(json, 'tomorrow')
\     ],
\   }

  endif
endfunction

function! s:get_forecast_daily(json, day)
  let sym_to_num = { 'today': 0, 'tomorrow': 1 }
  let f = a:json.forecasts[sym_to_num[a:day]]

  let daily = {}
  let daily.title = f.dateLabel
  let daily.description = f.telop
  let daily.parameters = []

  if has_key(f, 'temperature')
    let temp = f.temperature
    for item in [{"key": "max", "title": "最高気温"}, {"key": "min", "title": "最低気温"}]
      if has_key(temp, item.key)
        if type(temp[item.key]) == type({}) && has_key(temp[item.key], 'celsius')
          call add(daily.parameters, { 
\           "title": item.title,
\           "text":  temp[item.key].celsius . " 度"
\         })
        endif
      endif
    endfor
  endif

  return daily
endfunction

function! s:fetch_point_file(filename, dirname)
  let res = webapi#http#get(s:area_url)
  if res.status != '200'
    echo "[" . res.status . ":" . res.message . "]"
    return '';
  endif

  if !isdirectory(a:dirname)
    call mkdir(a:dirname, "p")
  endif
  call writefile([res.content], a:dirname . '/' . a:filename)

  return res.content
endfunction

function! s:load_point_file()
  let cachedir = g:unite_weather_directory . '/livedoor'
  let filename = 'area.xml'
  if !filereadable(cachedir . '/' . filename)
    call s:fetch_point_file(filename, cachedir)
  endif

  let xml = join(readfile(cachedir . '/' . filename))

  return webapi#xml#parse(xml)
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

