# 论坛、阶段、私信与分支叙事

## 信息架构

Forus 首页包含站点导航、日期、阶段状态、通知、版块、最新帖子和私信入口。私信入口始终存在；未触发的线程不显示联系人或占位。

帖子详情包含首帖、评论、回复、赞同和反对。阶段刷新时，当前阶段所有帖子同时可见。玩家可以对任意帖子互动，也可以不互动。

## 阶段推进

玩家点击“查看最新”结束当前阶段。按钮不会要求玩家完成指定互动，也不会因为未读帖子而阻塞。阶段结束后执行 `on_end`，然后刷新下一阶段帖子。

每天最后阶段结束后显示一次剧情总结，并按顺序执行：

1. 结算隐藏数值与互动结果。
2. 发放线索、证物或提升证物置信度。
3. 显示当天总结与已解锁信息。
4. 保存当前周目。
5. 进入下一日。

## 预设互动

```text
create_post
create_comment
create_reply
react_agree
react_disagree
reply_direct_message
```

互动无次数消耗。已执行选项由 `once` 控制。玩家不能自由输入文本。

## 私信

私信对象只有目标人物和 `Forus社区管理员`。玩家不能主动新建私信，只能回复剧情触发的来信。

触发条件来自公开互动。例如，玩家在目标人物求助帖下选择尊重隐私的支持回复后，目标人物在下一阶段发现玩家并发来私信；玩家完成举报或账号保护互动后，`Forus社区管理员` 才会发来私信。

私信以对话框展示。阅读不推进阶段，回复不消耗次数。私信内容严格不可外传，也不能直接成为公开证物或提升 `truth_confidence`。

## 日期分支

### 第 3 日

- `target_safety >= 2`：目标人物提供完整时间线，并承认自己的错误。
- 否则：目标人物停止私信，只留下未发送的道歉草稿。
- `truth_confidence >= 2`：解锁草稿版本和授权记录。

### 第 5 日

- `truth_confidence >= 4 && platform_governance >= 2`：Forus 开启正式复核。
- `target_safety <= 1`：目标人物进入账号停用与现实支持危机支线。
- `player_exposure >= 3`：玩家账号开始被集中检索。

### 第 6 日

按顺序设置 `ending_path`：

1. `player_exposure >= 4` → `player_targeted_path`
2. `target_safety <= 1 && truth_confidence < 4` → `target_danger_path`
3. `truth_confidence >= 4 && platform_governance >= 3` → `harassment_stop_path`
4. `target_safety >= 4` → `target_rescue_path`
5. 其他情况 → `target_danger_path`

第 7 日只收束已形成的分支，不通过最后一个按钮临时改变结局。
