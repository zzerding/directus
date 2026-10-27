# Fork 运行手册(zzerding/directus)

Directus 安全 fork,目的:在 BUSL 授权窗口内(2029-04-30 转 GPL v3 前)以 11.17.4 为基线自维护安全补丁,不升 12(license enforcement + Core 档压线)。

## 分支模型

- `fork/11.17.4`:**默认分支**,线性 backport 工作分支,所有安全补丁进这里。
- `base/11.17.4` tag:冻结基线锚点(`452c0ea`,上游 `v11.17.4` + fork 工具链),永不改写。
- `main`:纯上游镜像,仅作 fetch/diff 参照,不放 fork 文件,可随时 fast-forward 同步上游。
- 上游 remote `directus/directus` 已配好,cherry-pick 源。
- fork 的 Actions 里官方 workflow 保持禁用;只保留 `fork-image` / `fork-ci` / `fork-osv-watch` 三个。

## 发版流程

1. 补丁进 `fork/11.17.4`(重写实现,不 cherry-pick 12 的 MSCL 代码)。
2. `sh fork-tools/smoke.sh` 本地过(或依赖 CI 内置 smoke)。
3. 打 tag `11.17.4-sec.N` 推送 → CI 自动:构建 linux/amd64 → 容器冒烟 → 推 `ghcr.io/zzerding/directus:<tag>`(配置 `FORK_ALIYUN_*` var/secret 后同步推 Aliyun)。
4. `SECURITY_BACKPORTS.md` 记台账。
5. 部署:`zuohao-server/Dockerfile` 的 `FROM` 换成新镜像 → 重建包装镜像 → `make start`(首次升级需启用 swarm 里 migrate entrypoint 注释行)。

## 监控

- 自动:`fork-osv-watch` workflow(触发器在 main,每周一 10:30 北京时间)checkout `fork/11.17.4` 跑 `fork-tools/osv-watch.sh`,新 GHSA 自动开 issue(标签 `osv-tripwire`,含 CVSS/修复版本/上游参考 + triage 清单)。
- triage 处置:修复 → 重写实现 + smoke + tag `11.17.4-sec.N` + 台账;接受 → 追加 `fork-tools/.known-osv-ids` + 台账“已知未修复” + 关 issue。
- 手动:Actions → fork-osv-watch → Run workflow(可填 TEST_ID 强制测试);本地 `DRY_RUN=1 sh fork-tools/osv-watch.sh <GHSA-ID>` 预览,`sh fork-tools/osv-check.sh` 仍可单独查询。
- triage 规则见 SECURITY_BACKPORTS.md。

## Kill criteria(重评升级 12 的信号)

- 单个 backport > 300 行;
- 半年内 ≥ 4 个必修补丁;
- 出现不重构就修不了的架构级漏洞。

## 合规日历

- 每年:确认总财务 ≤ $5M(BUSL Additional Use Grant)。
- `license` 文件:随上游,不得删除。
- 不对外提供 Directus 服务(仅自用产品后端)。
- **2029-04-30**:Change Date,届时自动转 GPL v3(fork 义务随之了结)。

## 已知事项

- ghcr 包首次推送后默认 private;需要服务器匿名拉取时到 GitHub → Packages → directus 改 public。
- CI 用 GHA cache 缓存 pnpm 层;首次构建 ~7min,之后显著加快。
- scheduled workflow 只认默认分支,`fork-osv-watch` 的触发器因此必须留在 `fork/11.17.4` 上,删除该文件会静默停掉每周告警。
- 12 的 `.env` 变化(IP_TRUST_PROXY 等)与本 fork 无关;若将来升 12 再处理。
