# SECURITY_BACKPORTS 台账

基线:`v11.17.4`(上游 tag `1f9a05104`),镜像 `ghcr.io/zzerding/directus:11.17.4-sec.0`。

## 规则

- 每个 backport 一行,先进分支 `fork/11.17.4`,出镜像必须打 tag `*-sec.N`(N 递增)。
- triage 门槛:上游修复为 PR:N(非 breaking)且 CVSS ≥ 7 且本站配置可达 → 72h 内出补丁;其余按月批处理。
- 验收:红测试(复现脚本)→ 重写修复(不 cherry-pick MSCL 代码)→ `sh fork-tools/smoke.sh` 过 → 记台账。

## 台账

| 日期 | 漏洞 ID | 上游修复 | 进入镜像 | 备注 |
|---|---|---|---|---|
| 2026-10-27 | — | — | 11.17.4-sec.0 | 基线,无 backport |

## 已知未修复(接受风险,随基线升级重评)

| GHSA | CVE | 修复版本 | 本站不可达原因 |
|---|---|---|---|
| GHSA-c6w9-5g5j-jh2p | CVE-2026-61836 | 12.0.0 | 缓存 key 污染;本站 `CACHE_ENABLED` 未开启 |
| GHSA-j5h6-vqc3-phqh | CVE-2026-61835 | 12.0.0 | 0.0.0.0 SSRF;本站无触发该请求面的配置 |

基线升级(如 rebase 到 11.18.x)后运行 `sh fork-tools/osv-check.sh <新版本> --update` 重置基线并重评本表。

## 参考:11.10.2 → 11.17.4 已消化的 17 个

完整清单见 handoff 产物 `/tmp/osv_directus.json`(临时文件);OSV 查询 `package=directus ecosystem=npm` 可随时重建。
