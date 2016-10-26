# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Ytctapi.Repo.insert!(%Ytctapi.SomeModel{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Ytctapi.Repo.insert!(%Ytctapi.Transscript{
	ytid: "zCJaRJrW7GQ", 
	title: "饅頭日記02 - 饅頭的願望",
	language: "zh/zh",
	lines: "[{\"t\",\"\",\"q\":\"\",\"a\":\"\"},{\"t\",\"\",\"q\":\"\",\"a\":\"\"}]"})