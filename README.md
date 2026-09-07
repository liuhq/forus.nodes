# Forus Nodes

Forus Nodes 是一款以拟真论坛为主要界面的文本互动与卡牌 Roguelike 网页游戏，也是一个为期六个月的全栈求职作品集项目。

玩家生活在依靠基础网络维系的 13 号节点城（Node 13，简称 NC13）。论坛 Forus 将分散的居民组织成可持续的社会联系，而断开网络的城市会逐渐受到死寂数据（Dead Data）的现实侵蚀。玩家从论坛首页进入不同日期的《浔声小报》，通过预设选项发帖、评论和回复，调查异常事件，并用卡牌化的信息攻防改变故事结果。

## 首发内容

- 浔声小报（6 月 23 日）：两章新手故事。无人认领的旧物从已经消失的“南厝”重新寄出，玩家将在《错投》和《签收》中决定这些物品与历史能否找到真正的主人。
- 浔声小报（11 月 5 日）：三章分支故事。来自 NC7 的休谟（HUMO）在不知情的情况下被卷入秘密试验 H-5，离线用户的账号开始被“聚合单元”代行。
- 论坛之外没有传统关卡菜单：故事入口、个人页、存档状态、线索和战斗都嵌入站点页面与导航。
- 无图片素材。论坛主体使用 HTML、CSS 和排版塑造真实感，WebGL 仅用于背景、转场、卡牌反馈和死寂侵蚀等视觉效果。

## 技术方向

- 前端：React、TypeScript、React Router、Tailwind CSS、i18next、React Three Fiber / Three.js。
- 后端：Go、Gin、Gorm、SQLite，仅提供用户名密码认证和云存档。
- 内容：按章节维护的中英 YAML，使用稳定 ID 对齐结构、分支和本地化文本。
- 质量：单元测试、组件测试、端到端测试、内容 schema 校验、无障碍检查和 WebGL 降级。

项目文档从 [docs/design/overview.md](docs/design/overview.md) 开始；六个月排期见 [docs/roadmap.md](docs/roadmap.md)，内容制作规范见 [docs/content-pipeline.md](docs/content-pipeline.md)。原始需求保留在 [BRIEF.md](BRIEF.md)。

## 许可

项目代码计划采用 Mozilla Public License 2.0（MPL-2.0），许可证文件将在仓库初始化时补充。

游戏设计、世界观、剧情文本及其他游戏内容采用 Creative Commons Attribution-ShareAlike 4.0 International（CC BY-SA 4.0）许可。
