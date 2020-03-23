import os, osproc, times, browsers, json, strutils, encodings, uri, rdstdin, std/compilesettings

template isSsd(): bool =
  when defined(linux): # Returns `true` if main disk is SSD (Solid). Linux only
    try: readFile("/sys/block/sda/queue/rotational") == "0\n" except: false

proc getSystemInfo*(title, labels: string): JsonNode =
  result = %*{
    "title": title,
    "labels": labels,
    "compiled": CompileDate & "T" & CompileTime,
    "NimVersion": NimVersion,
    "hostCPU": hostCPU,
    "hostOS": hostOS,
    "cpuEndian": cpuEndian,
    "getTempDir": getTempDir(),
    "getHomeDir": getHomeDir(),
    "getConfigDir": getConfigDir(),
    "now": $now(),
    "getCurrentEncoding": getCurrentEncoding(),
    "getFreeMem": getFreeMem(),
    "getTotalMem": getTotalMem(),
    "getOccupiedMem": getOccupiedMem(),
    "countProcessors": countProcessors(),
    "ssd": isSsd(),
    "FileSystemCaseSensitive": FileSystemCaseSensitive,
    "nimcacheDir": querySetting(SingleValueSetting.nimcacheDir),
    "ccompilerPath": querySetting(SingleValueSetting.ccompilerPath),
    "nimpretty": execCmdEx("nimpretty --version").output.strip,
    "nimble": execCmdEx("nimble --noColor --version").output.strip,
    "nimgrep": execCmdEx("nimgrep --nocolor --version").output.strip,
    "nimsuggest": execCmdEx("nimsuggest --version").output.strip,
    "choosenim": if findExe"choosenim".len > 0: execCmdEx("choosenim --noColor --version").output.strip else: "",
    "gcc": if findExe"gcc".len > 0: execCmdEx("gcc --version").output.strip else: "",
    "clang": if findExe"clang".len > 0: execCmdEx("clang --version").output.strip else: "",
    "git": if findExe"git".len > 0: execCmdEx("git --version").output.strip else: "",
    "node": if findExe"node".len > 0: execCmdEx("node --version").output.strip else: "",
    "uname": execCmdEx(when defined(windows): "systeminfo" else: "uname -a").output.strip,
    "python": if findExe"python".len > 0: execCmdEx("python --version").output.strip else: ""
  }

proc getLink*(user, repo, title, labels, assignee: string, links: seq[string]): string =
  var body = ("\n\n# System Information\n\n<details>\n\n```json\n\n" &
    getSystemInfo(title, labels).pretty & "\n```\n\n</details>\n\n")
  if labels.len > 0:
    body.add "# Proposed Labels\n\n```csv\n" & labels & "\n```\n\n"
  if assignee.len > 0:
    body.add "# Proposed Assignee\n\n* <kbd>" & assignee & "</kbd>\n\n"
  if links.len > 0:
    body.add "# Links\n\n"
    for i, url in links: body.add $i & ". " & url & "\n"
    body.add "\n\n"
  result = ("https://github.com/" & user & "/" & repo & "/issues/new?" &
    encodeQuery({"title": title, "labels": labels, "assignee": assignee, "body": body}))

proc reportBug*(user, repo, title, labels, assignee: string, links: seq[string]) =
  let linky = getLink(user, repo, title, labels, assignee, links)
  when not defined(release): echo linky
  openDefaultBrowser linky

proc main() =
  const defaultUser {.strdefine.} = ""
  const defaultRepo {.strdefine.} = ""
  var title, labels, assignee, user, repo, link: string
  when defaultUser.len > 0 and defaultRepo.len > 0:
    user = defaultUser
    repo = defaultRepo
  else:
    while user.len == 0:
      user = readLineFromStdin("GitHub Username or Team of the project?: ").strip
    while repo.len == 0:
      repo = readLineFromStdin("GitHub Repository of the project?: ").strip
  while title.len == 0:
    title = readLineFromStdin("Issue report short and descriptive Title? (Must not be empty): ").strip
  labels = readLineFromStdin("Issue report proposed Labels? (Comma separated, can be empty): ").strip
  assignee = readLineFromStdin("Issue report 1 proposed Assignee? (GitHub User, can be empty): ").normalize.strip
  var links = newSeqOfCap[string](9)
  for _ in 1..9:
    link = readLineFromStdin("Links with useful info/pastebin?  (9 Links max, can be empty): ").toLowerAscii.strip
    if link.len == 0: break else: links.add link
  reportBug(user, repo, title, labels, assignee, links)


when isMainModule:
  if paramCount() > 0: quit"NimBug is an interactive tool, run it without arguments"
  main()
