# unite-weather.vim

## はじめに

unite-weather.vim は天気予報の API から天気予報を取得し表示するための Unite source です。

## インストール手順

    NeoBundle 'syurazo/unite-weather.vim'

## 使い方

### Unite source で都市を選択して天気予報を表示する

 * デフォルトの予報提供元を使用する場合

    :Unite weather

 * 予報提供元として 'livedoor' を指定する場合

    :Unite weather:livedoor

 * 特定の地域に絞る場合

    :Unite weather:livedoor:東京都

### 都市を指定して天気予報を表示する

 * 都市の ID を指定して、Unite を経由せず直接天気予報を表示する場合

    :WeatherForecast livedoor  130010

 * 都市名を指定して、Unite を経由せず直接天気予報を表示する場合

    :WeatherForecast livedoor  東京

 * 都市の名称から ID を検索する方法

    :WeatherNameToId 東京
    130010

## オプション変数

### g:unite_weather_directory

 エリア情報などのキャッシュを保存するディレクトリを指定する。

 デフォルトは unite#get_data_directory().'/weather' が設定されている。

### g:unite_weather_open

 結果を表示するバッファの開き方を指定する。

 デフォルトは 'new' が設定されている。

### g:unite_weather_default_provider

 ':Unite weather' で提供元を指定しなかった場合のデフォルトの提供元を指定する。

 デフォルトは 'livedoor' が指定されている。

### g:unite_weather_template_file

 天気予報の表示形式を記述したテンプレートファイルのファイル名を指定する。

 デフォルトは '' が設定され、デフォルトテンプレートが使われる。

## テンプレート

 表示するパラメタを {{ }} で括って記述する。

      【 {{publisher}} 】
      
      {{title}}
      
      {{description}}
      
      今日の天気
      {{daily.today.description}}
      最高気温 {{daily.today.temperature.max.text}} ／ 最低気温 {{daily.today.temperature.min.tex
      
      明日の天気
      {{daily.tomorrow.description}}
      最高気温 {{daily.tomorrow.temperature.max.text}} ／ 最低気温 {{daily.tomorrow.temperature.m

