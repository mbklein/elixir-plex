import Config

config :codepagex, :encodings, [
  :ascii,
  :iso_8859_1,
  "VENDORS/MICSFT/WINDOWS/CP1252"
]

import_config "#{Mix.env()}.exs"

if File.exists?("config/#{Mix.env()}.local.exs"),
  do: import_config("#{Mix.env()}.local.exs")
