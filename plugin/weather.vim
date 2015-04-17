"=============================================================================
" File    : weather.vim
" Author  : syurazo <syurazo@gmail.com>
" License : MIT license
"=============================================================================
if exists('g:loaded_unite_source_weather')
  finish
endif

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=+ WeatherForecast call s:call_weather_forecast(<f-args>)
function! s:call_weather_forecast(provider, id)
  call unite#sources#weather#forecast(a:provider, a:id)
endfunction

command! -nargs=+ WeatherNameToId call s:call_weather_name_to_id(<f-args>)
function! s:call_weather_name_to_id(provider, name)
  echo unite#sources#weather#name_to_id(a:provider, a:name)
endfunction

let g:loaded_unite_source_weather = 1

let &cpo = s:save_cpo
unlet s:save_cpo

