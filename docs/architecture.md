# 技术架构

## 架构目标

项目采用前端主导的单页叙事应用。内容包、阶段推进、公开互动、私信、隐藏数值和本地存档在浏览器执行；当前仓库尚未实现这些运行时，本阶段先固化规格和内容。

## 前端模块

- `AppShell`：Forus 导航、日期、阶段和私信入口。
- `ForumDomain`：版块、帖子树、评论、回复、赞同和反对。
- `StoryRuntime`：阶段刷新、条件、效果、隐藏数值和结局分支。
- `DirectMessageDomain`：触发式私信列表、对话框、预设回复和私密状态。
- `EvidenceDomain`：线索、证物和置信度。
- `SaveDomain`：阶段、私信和每日结算的本地存档。

删除 `CombatDomain`、战斗路由和战斗存档。

## 推荐路由

```text
/
/boards/:boardId
/threads/:threadId
/profile
/messages
/settings
```

私信可以使用 `/messages` 页面，并在页面内以对话框打开具体线程。

## 数据流

```text
日期内容 + 当前阶段 + 存档 + 玩家互动
              ↓
       条件判定与事务效果
              ↓
论坛状态 / 私信 / 线索 / 证物 / 隐藏数值
              ↓
       查看最新 → 阶段结算 → 每日总结
```

## 内容加载

内容管线校验中英文结构、阶段顺序、引用、私信触发条件、证物置信度和四个结局的可达性。`content_version` 与存档 `schema_version` 独立。
