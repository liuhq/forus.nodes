# 技术架构

## 架构目标

项目采用前端主导的单页应用。游戏规则、剧情解释、战斗和本地存档均在浏览器执行；后端不裁定游戏结果，只负责账号会话与版本化云存档。这样既突出 React 与 WebGL 能力，也让游客在后端不可用时完成全部游戏内容。

## 前端

### 模块边界

- 应用外壳（`AppShell`）：站点导航、响应式布局、全局错误边界和路由出口。
- 论坛域（`ForumDomain`）：版块、帖子、评论、回复、通知、搜索外观和个人页。
- 剧情运行时（`StoryRuntime`）：载入故事包、判断条件、执行效果、保存检查点。
- 战斗域（`CombatDomain`）：固定种子随机数、抽牌、效果栈、敌方意图与结算。
- 内容仓库（`ContentRepository`）：按语言载入编译后的章节数据并校验内容版本。
- 存档域（`SaveDomain`）：本地持久化、版本迁移、云端同步与冲突处理。
- 视效层（`EffectsLayer`）：React Three Fiber 场景、质量档位和纯 CSS 降级。

路由建议：

```text
/
/boards/:boardId
/threads/:threadId
/compose/:choiceSetId
/profile
/profile/archive/:runId
/settings
/auth/login
/auth/register
```

论坛首页展示综合讨论（`general_discussion`）、浔声小报（6月23日）（`xunsheng_0623`）和浔声小报（11月5日）（`xunsheng_1105`）。第二期初始可见但不可进入，进入条件只检查第一期是否完成任意结局。

### 状态与数据流

剧情运行时使用纯函数处理事件：

```text
内容数据 + 当前存档 + 玩家交互
              ↓
         条件判定器
              ↓
          效果执行器
              ↓
 新帖子/状态/牌组/路由出口 → 本地保存 → 可选云同步
```

- 可序列化游戏状态是唯一事实来源，React 组件不私自保存剧情判定状态。
- 随机行为从周目种子（`run_seed`）派生，测试和问题复现使用同一随机序列。
- 已发布的发帖、评论和回复保存选项 ID 与渲染结果；本地化切换后使用选项 ID 重新读取对应语言文本。
- 当前周目状态与永久档案分开。历史线索和帖子可阅读，但不能满足当前周目条件。

### WebGL 与降级

WebGL 画布固定在论坛 DOM 后方或非关键覆盖层，不接管文字排版、焦点或按钮命中区域。质量档位（`EffectQuality`）包含 `high`、`balanced`、`low`、`off`：

- 桌面默认 `balanced`，根据帧率自动升降。
- 移动端默认 `low`，关闭昂贵后处理并限制设备像素比。
- `prefers-reduced-motion` 默认使用 `off` 或静态效果。
- WebGL 初始化失败时保持完整 DOM 游戏流程，仅禁用视觉反馈。

## 内容构建

源文件位于 `docs/scripts`，开发阶段通过内容构建脚本完成：YAML 解析、schema 校验、中英结构对齐、引用校验、分支可达性分析和 JSON 输出。运行时只读取构建后的 JSON，不在客户端解析 YAML。

内容版本（`content_version`）与存档 schema 版本（`schema_version`）独立。文本修订通常只提升内容版本；字段或语义变化才提升 schema 版本并提供迁移函数。

## 后端与接口

API 使用 `/api/v1` 前缀，同源部署：

| 方法与路径 | 用途 |
|---|---|
| `POST /auth/register` | 创建用户名密码账号，可携带游客存档 |
| `POST /auth/login` | 建立服务端会话 |
| `POST /auth/logout` | 撤销当前会话 |
| `GET /auth/session` | 获取当前用户摘要 |
| `GET /save` | 获取云存档、修订号和更新时间 |
| `PUT /save` | 使用 `If-Match` 替换完整云存档 |

注册、登录和存档响应使用统一错误结构（`ApiError`）：

```json
{
  "error": {
    "code": "save_conflict",
    "message": "可本地化的安全提示",
    "request_id": "opaque-id"
  }
}
```

云存档包（`SaveEnvelope`）至少包含：

```text
schema_version
content_version
revision
updated_at
settings
current_run
permanent_archive
```

`PUT /save` 必须携带最近一次读取到的 ETag。修订不匹配返回 `409 save_conflict` 和云端摘要，客户端展示本地/云端的更新时间、故事、章节和结局数，由玩家选择覆盖方向；不自动合并分支状态。

## 安全

- 使用 Argon2id 生成密码哈希，每个密码使用独立随机盐；参数记录在哈希编码中以支持升级。
- 会话令牌使用密码学安全随机数，只将令牌哈希存入 SQLite。
- Cookie 设置 `HttpOnly`、`Secure`、`SameSite=Lax` 和明确生命周期；登录和登出时轮换或撤销会话。
- 同源部署并验证 `Origin`；所有状态变更接口拒绝异常来源。
- 对注册和登录按 IP 与用户名维度限流，错误信息不暴露用户名是否存在。
- 限制用户名、密码和存档请求体大小；服务端校验存档版本和结构，但不接受可执行内容。
- Gorm 迁移在启动前执行显式版本检查；SQLite 开启外键、WAL 和合理的忙等待时间。

## 部署与可观测性

前端静态产物与 Go API 同源提供。生产环境记录结构化请求日志、请求 ID、响应时间、状态码、登录限流和存档冲突计数；禁止记录密码、会话令牌与完整存档正文。提供健康检查和就绪检查，并在发布前备份 SQLite 数据库。
