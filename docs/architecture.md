# 技术架构

## 架构目标

项目采用前端主导的单页应用。游戏规则、日期推进、战斗和本地存档均在浏览器执行；后端只负责账号会话与版本化云存档。WebGL 是可缺席的适配包，不得成为任何核心模块的依赖。

## 前端模块

- 应用外壳（`AppShell`）：导航、路由、错误边界和首次进入/继续周目。
- 论坛域（`ForumDomain`）：版块、帖子树、通知、档案和个人页。
- 故事运行时（`StoryRuntime`）：加载单故事包、日期额度、条件、效果与出口。
- 战斗域（`CombatDomain`）：固定种子、三堆牌、双方数值、意图与结算。
- 内容仓库（`ContentRepository`）：按日期与语言加载编译 JSON。
- 存档域（`SaveDomain`）：IndexedDB、迁移、云同步与冲突。
- 视效端口（`EffectsPort`）：声明语义视效事件并默认使用无操作实现。

路由建议：

```text
/
/boards/:boardId
/threads/:threadId
/compose/:choiceSetId
/combat/:encounterId
/profile
/profile/archive/:runId
/settings
/auth/login
/auth/register
```

首次访问 `/` 自动创建或恢复《H-5》周目。不存在故事目录、故事选择路由和第二故事访问条件。

## 状态与数据流

```text
日期内容 + 当前存档 + 玩家动作
              ↓
      条件判定与事务式效果
              ↓
论坛状态 / 路线 / 牌组 / 战斗
              ↓
       日期出口 → 本地保存 → 可选云同步
```

- 可序列化状态是唯一事实来源，React 组件不得私存剧情判定状态。
- 随机行为由 `run_seed` 派生，存档同时保存随机序列位置。
- 已发布楼层保存选项 ID；切换语言后按 ID 读取对应文本。
- 日期结束效果使用幂等标记，战斗重试不能再次执行。
- 运行时遍历 `StoryPackage.days`，不允许使用常量 7 判断完成。

## 可选视效架构

```text
Core UI / Story / Combat
          ↓ semantic events
     EffectsAdapter
       ↙         ↘
NoopEffectsAdapter  optional WebGLEffectsAdapter
```

`EffectsAdapter` 只暴露 `mount`、`emit`、`setQuality`、`dispose`。事件包含页面切换、异常显现、出牌、受击、日期变化和结局；载荷只能使用核心定义的可序列化类型。

核心包默认注册 `NoopEffectsAdapter`。WebGL 包通过动态导入和运行时注册加载，核心代码不得导入 Three.js 或 React Three Fiber。缺包、初始化失败、上下文丢失或关闭视效时回退到 DOM/CSS，不阻断操作、不改变状态。

## 内容构建

构建脚本执行 YAML schema 校验、中英结构对齐、引用校验、日期连续性、路线与结局可达性分析，再输出按日期和语言拆分的 JSON。`content_version` 与 `schema_version` 独立。

## 后端接口

API 使用 `/api/v1`：注册、登录、登出、会话查询、读取存档和带 `If-Match` 的完整存档替换。修订冲突返回 `409 save_conflict`，客户端让玩家选择本地或云端完整覆盖。

密码使用 Argon2id；会话仅存令牌哈希；Cookie 设置 `HttpOnly`、`Secure`、`SameSite=Lax`。验证 Origin、限制认证频率和请求体大小，日志不得记录密码、令牌或完整存档。

## 部署

前端静态产物与 Go API 同源提供。基础生产构建不得包含或要求 WebGL 包。结构化日志记录请求 ID、耗时、状态码、限流和冲突计数；SQLite 启用外键、WAL 和忙等待，并在发布前备份。
