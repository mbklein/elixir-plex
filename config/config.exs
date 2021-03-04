import Config

config :codepagex, :encodings, [
  "VENDORS/MICSFT/WINDOWS/CP1252",
  :iso_8859_1,
  :ascii
]

import_config "#{Mix.env()}.exs"

if File.exists?("config/#{Mix.env()}.local.exs"),
  do: import_config("#{Mix.env()}.local.exs")
