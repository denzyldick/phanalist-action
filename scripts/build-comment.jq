($sarif[0]) as $doc
| ($annotations[0] // []) as $ann
| ($doc.runs[0].tool.driver.rules // []) as $rules

| def result_rule_id($a):
    first(
      $doc.runs[].results[]?
      | select(
          (.locations[0].physicalLocation.artifactLocation.uri == $a.path)
          and ((.locations[0].physicalLocation.region.startLine // 0) == ($a.start_line // 0))
          and ((.message.text // "") == ($a.message // ""))
        )
      | .ruleId
    ) // "";

  def rule_doc($id):
    first(
      $rules[]
      | select(.id == $id)
      | (.help.markdown // .help.text // .fullDescription.markdown // .fullDescription.text // "")
    ) // "";

  def rule_name($id):
    first(
      $rules[]
      | select(.id == $id)
      | (.shortDescription.text // .name // $id)
    ) // $id;

  def alert_lines($alerts):
    $alerts
    | group_by(.ruleId)
    | map(
        . as $g
        | "### `\($g[0].ruleId)` \($g[0].name)\n\n"
          + ($g | map("- `\(.path):\(.line)` — \(.message)") | join("\n"))
          + "\n\n"
      )
    | join("");

  def header($alerts):
    "<!-- phanalist-action -->\n"
    + "## Phanalist alerts in this pull request\n\n"
    + "Phanalist found **\($alerts | length)** new alert\(if ($alerts | length) == 1 then "" else "s" end) in the changed code.\n\n";

  [ $ann[]
    | . as $a
    | (result_rule_id($a)) as $rid
    | select($rid != "")
    | {
        path: ($a.path // ""),
        line: ($a.start_line // 0),
        message: ($a.message // ""),
        ruleId: $rid,
        name: rule_name($rid),
        docs: rule_doc($rid)
      }
  ] as $alerts

| if ($alerts | length) == 0 then
    "<!-- phanalist-action -->\n"
    + "## Phanalist alerts in this pull request\n\n"
    + "No new Phanalist alerts in the changed code.\n\n"
    + "[View code scanning alerts](\($alerts_url))\n"
  else
    (header($alerts) + alert_lines($alerts) + "[View code scanning alerts](\($alerts_url))\n") as $compact
    | (header($alerts)
       + ( $alerts
           | group_by(.ruleId)
           | map(
               . as $g
               | "### `\($g[0].ruleId)` \($g[0].name)\n\n"
                 + ($g | map("- `\(.path):\(.line)` — \(.message)") | join("\n"))
                 + "\n\n<details>\n<summary>Full rule documentation: \($g[0].ruleId)</summary>\n\n"
                 + ($g[0].docs | if . == "" then "_No documentation available._" else . end)
                 + "\n\n</details>\n\n"
             )
           | join("")
         )
       + "[View code scanning alerts](\($alerts_url))\n") as $full
    | if ($full | length) > 60000 then $compact else $full end
  end
